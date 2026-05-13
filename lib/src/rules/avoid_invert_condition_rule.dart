import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidInvertConditionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_invert_condition',
    'Avoid inverting conditions',
    correctionMessage: 'Avoid inverting conditions',
  );

  AvoidInvertConditionRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _Visitor(this));
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidInvertConditionRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    _checkExpression(node.expression);
  }

  void _checkExpression(Expression expression) {
    final current = _unwrap(expression);

    if (current case BinaryExpression(leftOperand: final left, rightOperand: final right, operator: final operator)) {
      _checkExpression(left);
      _checkExpression(right);

      if (!_isComparisonOperator(operator.type)) {
        return;
      }

      final normalizedLeft = _unwrap(left);
      final normalizedRight = _unwrap(right);

      if (_isSimpleLiteral(normalizedLeft) && !_isSimpleLiteral(normalizedRight)) {
        rule.reportAtNode(current);
      }
    }
  }

  bool _isSimpleLiteral(Expression expression) {
    return expression is IntegerLiteral ||
        expression is DoubleLiteral ||
        expression is BooleanLiteral ||
        expression is NullLiteral ||
        expression is SimpleStringLiteral;
  }

  Expression _unwrap(Expression e) {
    var current = e;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }

  bool _isComparisonOperator(TokenType type) {
    return switch (type) {
      TokenType.EQ_EQ ||
      TokenType.BANG_EQ ||
      TokenType.GT ||
      TokenType.GT_EQ ||
      TokenType.LT ||
      TokenType.LT_EQ => true,
      _ => false,
    };
  }
}
