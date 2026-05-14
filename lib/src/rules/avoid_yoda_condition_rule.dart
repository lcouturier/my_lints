import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';


/// A lint rule that detects Yoda conditions, where a literal is on the left side of a comparison operator.
/// For example, `if (5 == x)` is a Yoda condition, while `if (x == 5)` is not.
/// Yoda conditions can be less readable and harder to understand, especially for developers who are not familiar with the concept.
/// This rule encourages developers to write conditions in a more natural and readable way by placing the variable on the left side of the comparison operator.
/// https://en.wikipedia.org/wiki/Yoda_conditions
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

/// A visitor that checks for Yoda conditions in if statements. It visits each if statement and applies the _ConditionVisitor to its condition expression.
/// The _ConditionVisitor checks for Yoda conditions in binary expressions within the if statement's condition.
class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidYodaConditionsRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    node.expression.accept(_ConditionVisitor(rule));
  }
}

/// A visitor that checks for Yoda conditions in binary expressions within if statements.
/// It visits each binary expression and checks if the left operand is a simple literal and the right operand is not.
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
    }
  }
}
