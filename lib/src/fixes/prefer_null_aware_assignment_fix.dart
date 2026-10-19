import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_assignment_rule.dart';

class PreferNullAwareAssignmentFix extends ResolvedCorrectionProducer with _PreferNullAwareAssignmentMixin {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareAssignment',
    DartFixKindPriority.standard,
    'Prefer null-aware assignment',
  );

  PreferNullAwareAssignmentFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! IfStatement || targetNode.nullAwareAssignmentCandidate == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement(targetNode));
    });
  }

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;
}

class PreferNullAwareAssignmentFixInFile extends ResolvedCorrectionProducer with _PreferNullAwareAssignmentMixin {
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
      for (final occurrence in visitor.occurrences) {
        builder.addSimpleReplacement(range.node(occurrence), replacement(occurrence));
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<IfStatement> occurrences = [];

  @override
  void visitIfStatement(IfStatement node) {
    if (node.nullAwareAssignmentCandidate != null) occurrences.add(node);
    super.visitIfStatement(node);
  }
}

mixin _PreferNullAwareAssignmentMixin {
  String replacement(IfStatement node) {
    final name = (node.expression as BinaryExpression).leftOperand as SimpleIdentifier;
    final rightValue = node.nullAwareAssignmentCandidate!.rightHandSide;

    return '$name ??= $rightValue;';
  }
}
