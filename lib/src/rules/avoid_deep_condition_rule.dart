import 'dart:math' as math;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidDeepConditionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_deep_conditions',
    'Condition is nested too deeply.',
    correctionMessage: 'Extract parts of the condition into well-named boolean variables.',
  );

  AvoidDeepConditionsRule({required this.maxDepth}) : super(name: code.name, description: code.problemMessage);

  final int maxDepth;

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);

    registry
      ..addIfStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addDoStatement(this, visitor)
      ..addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidDeepConditionsRule rule;

  @override
  void visitIfStatement(IfStatement node) {
    _check(node.expression);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _check(node.condition);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _check(node.condition);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _check(node.condition);
  }

  void _check(Expression expression) {
    final depth = _ConditionDepth.compute(expression);

    if (depth > rule.maxDepth) {
      rule.reportAtNode(expression);
    }
  }
}

final class _ConditionDepth {
  static int compute(Expression expression) {
    final unwrapped = expression.unParenthesized;

    return switch (unwrapped) {
      PrefixExpression(operator: Token(type: TokenType.BANG)) => 1 + compute(unwrapped.operand),
      ConditionalExpression() => 1 + math.max(compute(unwrapped.thenExpression), compute(unwrapped.elseExpression)),
      BinaryExpression(operator: Token(type: TokenType.AMPERSAND_AMPERSAND) || Token(type: TokenType.BAR_BAR)) =>
        1 + compute(unwrapped.leftOperand) + compute(unwrapped.rightOperand),
      _ => 1,
    };
  }
}
