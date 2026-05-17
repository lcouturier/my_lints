import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidYodaConditionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_yoda_conditions',
    'Avoid Yoda conditions.',
    correctionMessage: 'Consider reordering the operands to improve readability.',
  );

  AvoidYodaConditionsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _IfVisitor(this));
  }
}

class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidYodaConditionsRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    node.expression.accept(_ConditionVisitor(rule));
  }
}

class _ConditionVisitor extends RecursiveAstVisitor<void> {
  final AvoidYodaConditionsRule rule;

  _ConditionVisitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    if (!node.operator.type.isComparisonOperator) return;

    final left = node.leftOperand.unParenthesized;
    final right = node.rightOperand.unParenthesized;

    if (left.isSimpleLiteral && !right.isSimpleLiteral) {
      rule.reportAtNode(node);
      return;
    }

    /// Covers cases like `-1 == list.indexOf(5)`.
    if (node case BinaryExpression(
      leftOperand: PrefixExpression(operand: Literal(), operator: Token(type: TokenType.MINUS)),
      rightOperand: final rightOperand,
    ) when (!rightOperand.isSimpleLiteral)) {
      rule.reportAtNode(node);
    }
  }
}
