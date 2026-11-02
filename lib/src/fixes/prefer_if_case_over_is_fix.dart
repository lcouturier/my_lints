import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Quick-fix for `prefer_if_case_over_is`.
///
/// Transforms:
/// ```dart
/// if (value is SomeType) {
///   use(value.property);
/// }
/// ```
/// into:
/// ```dart
/// if (value case SomeType(:final property)) {
///   use(property);
/// }
/// ```
///
/// The fix collects every distinct property name accessed via `value.property`
/// (or `value?.property`) inside the then-branch, builds a destructuring
/// object pattern, and replaces each qualifying property access with the bare
/// variable name.
class PreferIfCaseOverIsFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferIfCaseOverIs',
    DartFixKindPriority.standard,
    'Convert to if-case pattern',
  );

  PreferIfCaseOverIsFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // `node` is the most-specific AST node at the selection offset.
    // The rule reports the IsExpression; we locate it (or its parent) from here.
    final isExpr = switch (node) {
      final IsExpression e => e,
      // The selection may land on the target identifier inside the IsExpression.
      _ => node.thisOrAncestorOfType<IsExpression>(),
    };

    if (isExpr == null) return;
    if (isExpr.notOperator != null) return;

    final ifStatement = isExpr.parent;
    if (ifStatement is! IfStatement) return;

    final target = isExpr.expression;
    if (target is! SimpleIdentifier) return;
    final targetName = target.name;

    final typeName = isExpr.type.toSource();

    // Collect every distinct property accessed as `targetName.prop` in the then-branch.
    final collector = _PropertyAccessCollector(targetName: targetName);
    ifStatement.thenStatement.visitChildren(collector);

    final propertyNames = collector.propertyNames.toList();
    if (propertyNames.isEmpty) return;

    // Build the destructuring pattern: `SomeType(:final prop1, :final prop2)`.
    final pattern = '$targetName case $typeName(${propertyNames.map((p) => ':final $p').join(', ')})';

    await builder.addDartFileEdit(file, (fileBuilder) {
      // 1. Replace the IsExpression (condition) with the case pattern.
      fileBuilder.addSimpleReplacement(range.node(isExpr), pattern);

      // 2. Replace every qualifying property access in the then-branch with
      //    the bare property name, in reverse source order to keep offsets valid.
      final accesses = collector.accesses.toList()..sort((a, b) => b.offset.compareTo(a.offset));

      for (final access in accesses) {
        fileBuilder.addSimpleReplacement(range.node(access.node), access.propertyName);
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A resolved property access together with its bare property name.
final class _PropertyAccess {
  _PropertyAccess({required this.node, required this.propertyName});

  /// The AST node covering the full `target.property` expression.
  final AstNode node;

  /// Offset of the node in the source.
  int get offset => node.offset;

  /// The property name (right-hand side of the dot).
  final String propertyName;
}

/// Collects all `targetName.prop` and `targetName?.prop` accesses inside a
/// subtree, deduplicating property names for the pattern while keeping every
/// individual access for replacement.
class _PropertyAccessCollector extends RecursiveAstVisitor<void> {
  _PropertyAccessCollector({required this.targetName});

  final String targetName;

  /// Ordered set of unique property names (insertion order preserved via [LinkedHashSet] semantics).
  final Set<String> propertyNames = <String>{};

  /// Every individual qualifying access node, used for textual replacement.
  final List<_PropertyAccess> accesses = [];

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == targetName) {
      final prop = node.identifier.name;
      propertyNames.add(prop);
      accesses.add(_PropertyAccess(node: node, propertyName: prop));
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.target case SimpleIdentifier(:final name) when name == targetName) {
      final prop = node.propertyName.name;
      propertyNames.add(prop);
      accesses.add(_PropertyAccess(node: node, propertyName: prop));
    }
    super.visitPropertyAccess(node);
  }
}
