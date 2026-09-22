import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferConstEmptyListAfterIfNullFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferConstEmptyListAfterIfNull',
    DartFixKindPriority.standard,
    'Use const [] as the if-null fallback',
  );

  PreferConstEmptyListAfterIfNullFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case BinaryExpression(
      operator: Token(type: TokenType.QUESTION_QUESTION),
      rightOperand: final ListLiteral rightOperand,
    ) when rightOperand.elements.isEmpty && rightOperand.constKeyword == null && rightOperand.typeArguments == null) {
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(rightOperand), 'const []');
      });
    }
  }
}

class PreferConstEmptyListAfterIfNullFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferConstEmptyListAfterIfNullFixInFile',
    DartFixKindPriority.inFile,
    'Use const [] as the if-null fallback in file',
  );

  PreferConstEmptyListAfterIfNullFixInFile({required super.context});

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
      for (final occurrence in visitor.occurrences.whereType<BinaryExpression>()) {
        builder.addSimpleReplacement(range.node(occurrence.rightOperand), 'const []');
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);
    if (node case BinaryExpression(
      operator: Token(type: TokenType.QUESTION_QUESTION),
      rightOperand: ListLiteral(elements: [], constKeyword: null, typeArguments: null),
    )) {
      occurrences.add(node);
    }
  }
}
