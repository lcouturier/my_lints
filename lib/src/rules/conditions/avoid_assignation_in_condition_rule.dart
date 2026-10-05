import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Avoid assignation in condition rule
class AvoidAssignationInConditionRule extends AnalysisRule {
  static final code = const LintCode(
    'avoid_assignation_in_condition',
    "Don't use assignation in condition.",
    correctionMessage: "Consider assigning the value to a variable before the condition.",
  );

  AvoidAssignationInConditionRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidAssignationInConditionRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(:final leftOperand) when leftOperand.unParenthesized is AssignmentExpression) {
      rule.reportAtNode(leftOperand.unParenthesized);
    }
  }
}
