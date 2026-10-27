import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_assignment_rule.dart';

class PreferNullAwareAssignmentFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareAssignment',
    DartFixKindPriority.standard,
    'Prefer null-aware assignment',
  );

  PreferNullAwareAssignmentFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node as IfStatement;
    final replacement = node.replacement;

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(node), (b) => b.write(replacement));
    });
  }

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;
}

class PreferNullAwareAssignmentFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareAssignmentInFile',
    DartFixKindPriority.inFile,
    'Replace all null-aware assignment in file',
  );

  PreferNullAwareAssignmentFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _Visitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences.whereType<IfStatement>()) {
        final replacement = occurrence.replacement;
        builder.addReplacement(range.node(occurrence), (b) => b.write(replacement));
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitIfStatement(IfStatement node) {
    if (node.isReplacable) {
      occurrences.add(node);
    }
    super.visitIfStatement(node);
  }
}

extension on IfStatement {
  /// Builds the Dart source string that replaces this `if` statement with the
  /// equivalent null-aware assignment `variable ??= value;`.
  ///
  /// Assumes the statement has already been validated by [isReplacable], so the
  /// expected AST shape (`variable == null` followed by a single assignment to
  /// the same variable) is guaranteed to hold.
  String get replacement {
    final name = (expression as BinaryExpression).leftOperand as SimpleIdentifier;
    final actualStatement = (thenStatement as Block).statements.single;
    final rightValue = ((actualStatement as ExpressionStatement).expression as AssignmentExpression).rightHandSide;

    return '$name ??= $rightValue;';
  }
}
