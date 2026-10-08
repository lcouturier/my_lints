import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Avoid assignation in condition rule
///
/// This rule detects when an assignment is used in a condition, which can lead to unexpected behavior.
/// Example:
/// ```dart
/// if (x = 5) { // ❌
///   // ...
/// }
/// ```
///
/// Correct:
/// ```dart
/// int x = 5; // ✅
/// if (x == 5) {
///   // ...
/// }
/// ```
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
    if (node case BinaryExpression(leftOperand: final leftOperand, rightOperand: final rightOperand)) {
      if (leftOperand.unParenthesized is AssignmentExpression || rightOperand.unParenthesized is AssignmentExpression) {
        rule.reportAtNode(node);
      }
    }
  }
}
