import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferContainsFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind('my_lints.fix.preferContains', DartFixKindPriority.standard, 'Replace with contains');

  PreferContainsFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! BinaryExpression) return;

    final left = targetNode.leftOperand;
    final right = targetNode.rightOperand;
    final equality = targetNode.operator.type == TokenType.EQ_EQ;

    final replacement = switch ((equality, left.isIndexOfCall)) {
      (false, true) => left.toSource().replaceFirst('indexOf', 'contains'),
      (true, true) => '!${left.toSource().replaceFirst('indexOf', 'contains')}',
      (false, false) => right.toSource().replaceFirst('indexOf', 'contains'),
      (true, false) => '!${right.toSource().replaceFirst('indexOf', 'contains')}',
    };

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

class PreferContainsFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferContainsInFile',
    DartFixKindPriority.inFile,
    'Replace all indexOf comparisons with contains in file',
  );

  PreferContainsFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferContainsVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences) {
        final left = occurrence.leftOperand;
        final right = occurrence.rightOperand;
        final equality = occurrence.operator.type == TokenType.EQ_EQ;

        final replacement = switch ((equality, left.isIndexOfCall)) {
          (false, true) => left.toSource().replaceFirst('indexOf', 'contains'),
          (true, true) => '!${left.toSource().replaceFirst('indexOf', 'contains')}',
          (false, false) => right.toSource().replaceFirst('indexOf', 'contains'),
          (true, false) => '!${right.toSource().replaceFirst('indexOf', 'contains')}',
        };

        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
    });
  }
}

class _PreferContainsVisitor extends RecursiveAstVisitor<void> {
  final List<BinaryExpression> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.isIndexOfComparedToMinusOne) {
      occurrences.add(node);
    }
    super.visitBinaryExpression(node);
  }
}
