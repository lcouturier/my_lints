// Avoid using conditional expressions in parameter values.

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidConditionalExpressionInParameterRule extends AnalysisRule {
  static final LintCode code = const LintCode(
    'avoid_conditional_expression_in_parameter',
    'Avoid using conditional expressions in parameter values.',
    correctionMessage: 'Try to avoid using conditional expressions in parameter values.',
  );
  AvoidConditionalExpressionInParameterRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidConditionalExpressionInParameterRule rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node.thisOrAncestorOfType<ArgumentList>() != null) {
      rule.reportAtNode(node);
      return;
    }

    if (node.thisOrAncestorOfType<NamedExpression>() != null) {
      rule.reportAtNode(node);
      return;
    }
  }
}
