import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects nested ternary operators.
///
/// Nested ternary operators make code harder to read and understand.
/// Use a regular if-else statement instead.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final result = condition1 ? (condition2 ? 'A' : 'B') : 'C';
/// ```
///
/// ✅ Good:
/// ```dart
/// String result;
/// if (condition1) {
///   result = condition2 ? 'A' : 'B';
/// } else {
///   result = 'C';
/// }
/// ```
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
    if (node case ConditionalExpression(thenExpression: ConditionalExpression())) {
      rule.reportAtNode(node.thenExpression);
    }
    if (node case ConditionalExpression(elseExpression: ConditionalExpression())) {
      rule.reportAtNode(node.elseExpression);
    }

    super.visitConditionalExpression(node);
  }
}
