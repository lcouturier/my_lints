import 'dart:math';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidComplicatedConditionalRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_complicated_conditionals',
    'Avoid complicated conditionals.',
    correctionMessage: 'Consider simplifying the conditional expression to improve readability.',
  );

  AvoidComplicatedConditionalRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _IfVisitor(this));
  }
}

class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidComplicatedConditionalRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final visitor = _ComplexConditionVisitor();

    node.expression.accept(visitor);

    if (visitor.score > 5 && visitor.maxNesting >= 3) {
      rule.reportAtNode(node.expression);
    }
  }
}

class _ComplexConditionVisitor extends RecursiveAstVisitor<void> {
  int logicalOperators = 0;
  int nesting = 0;
  int maxNesting = 0;
  int score = 0;

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      score += 1;
    }

    super.visitPrefixExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;

    if (operator == TokenType.AMPERSAND_AMPERSAND || operator == TokenType.BAR_BAR) {
      if (node.leftOperand is MethodInvocation || node.rightOperand is MethodInvocation) {
        score += 2;
      }

      score += 1;

      nesting++;
      maxNesting = max(maxNesting, nesting);

      super.visitBinaryExpression(node);

      nesting--;
      return;
    }

    super.visitBinaryExpression(node);
  }
}
