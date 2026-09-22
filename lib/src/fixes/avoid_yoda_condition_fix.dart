import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

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

class AvoidYodaConditionFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidYodaCondition',
    DartFixKindPriority.standard,
    'Swap the condition',
  );

  AvoidYodaConditionFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! BinaryExpression) return;

    final replacement = "${targetNode.rightOperand} ${targetNode.operator.type.lexeme} ${targetNode.leftOperand}";

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

class AvoidYodaConditionFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidYodaConditionFixInFile',
    DartFixKindPriority.inFile,
    'Swap all conditions...',
  );

  AvoidYodaConditionFixInFile({required super.context});

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
        final replacement = "${occurrence.rightOperand} ${occurrence.operator.type.lexeme} ${occurrence.leftOperand}";
        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);
    if (!node.operator.type.isComparisonOperator) return;
    if ((node.leftOperand.isConstant) && (!node.rightOperand.isConstant)) {
      occurrences.add(node);
    }
  }
}
