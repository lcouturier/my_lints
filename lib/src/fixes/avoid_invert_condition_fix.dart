import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

String? swappedComparisonOperatorLexeme(TokenType operatorType) {
  return switch (operatorType) {
    TokenType.EQ_EQ => TokenType.EQ_EQ.lexeme,
    TokenType.BANG_EQ => TokenType.BANG_EQ.lexeme,
    TokenType.GT => TokenType.LT.lexeme,
    TokenType.GT_EQ => TokenType.LT_EQ.lexeme,
    TokenType.LT => TokenType.GT.lexeme,
    TokenType.LT_EQ => TokenType.GT_EQ.lexeme,
    _ => null,
  };
}

class AvoidInvertConditionFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidInvertCondition',
    DartFixKindPriority.standard,
    'Swap the condition',
  );

  AvoidInvertConditionFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! BinaryExpression) return;

    final operatorLexeme = swappedComparisonOperatorLexeme(targetNode.operator.type);
    if (operatorLexeme == null) return;

    final replacement = "${targetNode.rightOperand} $operatorLexeme ${targetNode.leftOperand}";

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}
