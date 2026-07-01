import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferFirstFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind('my_lints.fix.preferFirst', DartFixKindPriority.standard, 'Replace  [0] with first');

  PreferFirstFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! IndexExpression) return;
    if (targetNode.index is! IntegerLiteral || (targetNode.index as IntegerLiteral).value != 0) return;

    final String replacement = '${targetNode.target}.first';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

class PreferFirstFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferFirstInFile',
    DartFixKindPriority.inFile,
    'Replace all [0] with .first in file...',
  );

  PreferFirstFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferFirstVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences) {
        final String replacement = '${(occurrence as IndexExpression).target}.first';
        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
    });
  }
}

class _PreferFirstVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.index is IntegerLiteral && (node.index as IntegerLiteral).value == 0) {
      occurrences.add(node);
    }
    super.visitIndexExpression(node);
  }
}
