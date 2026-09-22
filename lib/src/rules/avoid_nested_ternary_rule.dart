import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedTernaryRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_ternary',
    'Nested ternary operators can make code harder to read and understand.',
    correctionMessage: 'Consider using a regular if-else statement instead.',
  );

  AvoidNestedTernaryRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = AvoidNestedTernaryVisitor(this);
    registry.addConditionalExpression(this, visitor);
  }
}

class AvoidNestedTernaryVisitor extends RecursiveAstVisitor<void> {
  final AvoidNestedTernaryRule rule;

  AvoidNestedTernaryVisitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    final thenExpr = node.thenExpression.unParenthesized;
    final elseExpr = node.elseExpression.unParenthesized;

    if (thenExpr is ConditionalExpression || elseExpr is ConditionalExpression) {
      rule.reportAtNode(node);
    }

    super.visitConditionalExpression(node);
  }
}
