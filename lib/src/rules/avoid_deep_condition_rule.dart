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
    final depth = _ConditionDepth.compute(expression.unParenthesized);

    if (depth > rule.maxDepth) {
      rule.reportAtNode(expression);
    }
  }
}

final class _ConditionDepth {
  static int compute(Expression expression) {
    final unwrapped = expression.unParenthesized;

    return switch (unwrapped) {
      BinaryExpression() => 1,
      PrefixExpression(operator: Token(type: TokenType.BANG)) => 1 + compute(unwrapped.operand),
      ConditionalExpression() => 1,
      _ => 1,
    };

    // switch (unwrapped) {
    //   case BinaryExpression():
    //     return _binaryDepth(unwrapped);

    //   case PrefixExpression():
    //     return _prefixDepth(unwrapped);

    //   case ConditionalExpression():
    //     return 1 + math.max(compute(unwrapped.thenExpression), compute(unwrapped.elseExpression));

    //   default:
    //     // Toute comparaison / appel / accès est considéré
    //     // comme un atome logique.
    //     return 1;
    // }
  }

  static int _binaryDepth(BinaryExpression expression) {
    switch (expression.operator.type) {
      case TokenType.AMPERSAND_AMPERSAND:
      case TokenType.BAR_BAR:
        return 1 + math.max(compute(expression.leftOperand), compute(expression.rightOperand));

      default:
        // == != < > <= >= is is! etc.
        return 1;
    }
  }

  static int _prefixDepth(PrefixExpression expression) {
    if (expression.operator.type == TokenType.BANG) {
      return 1 + compute(expression.operand);
    }

    return 1;
  }
}
