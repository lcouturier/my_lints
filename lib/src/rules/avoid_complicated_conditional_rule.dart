import 'dart:math' as math;

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
    correctionMessage: 'Consider splitting the condition into smaller expressions.',
  );

  AvoidComplicatedConditionalRule({required this.threshold}) : super(name: code.name, description: code.problemMessage);

  final int threshold;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addIfStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addConditionalExpression(this, visitor)
      ..addDoStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidComplicatedConditionalRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    _verify(node.expression);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _verify(node.condition);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _verify(node.condition);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _verify(node.condition);
  }

  void _verify(Expression expression) {
    final condition = expression.unParenthesized;

    final metrics = _Metrics();
    metrics.analyze(condition);

    final score =
        metrics.logicalOps +
        metrics.negations +
        metrics.ternaries +
        (metrics.maxDepth >= 3 ? (metrics.maxDepth - 3 + 1) * 2 : 0);

    if (score >= rule.threshold) {
      rule.reportAtNode(expression);
    }
  }
}

class _Metrics {
  int logicalOps = 0;
  int negations = 0;
  int ternaries = 0;
  int maxDepth = 0;

  void analyze(Expression expression) {
    _visit(expression.unParenthesized, 0);
  }

  void _visit(Expression e, int depth) {
    // ignore: parameter_assignments
    e = e.unParenthesized;

    maxDepth = math.max(maxDepth, depth);

    switch (e) {
      case BinaryExpression(operator: final op, leftOperand: final left, rightOperand: final right):
        if (op.type == TokenType.AMPERSAND_AMPERSAND || op.type == TokenType.BAR_BAR) {
          logicalOps++;
        }

        _visit(left, depth + 1);
        _visit(right, depth + 1);
        return;

      case PrefixExpression(operator: final op, operand: final operand):
        if (op.type == TokenType.BANG) {
          negations++;
        }

        _visit(operand, depth + 1);
        return;

      case ConditionalExpression(condition: final cond, thenExpression: final thenExpr, elseExpression: final elseExpr):
        ternaries++;

        _visit(cond, depth + 1);
        _visit(thenExpr, depth + 1);
        _visit(elseExpr, depth + 1);
        return;

      default:
        return;
    }
  }
}

