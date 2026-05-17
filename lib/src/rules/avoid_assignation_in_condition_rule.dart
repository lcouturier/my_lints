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
    registry
      ..addIfStatement(this, visitor)
      ..addReturnStatement(this, visitor)
      ..addWhileStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidAssignationInConditionRule rule;

  _Visitor(this.rule);

  void _check(Expression expr) {
    expr.accept(_AssignmentVisitor(rule));
  }

  @override
  void visitIfStatement(IfStatement node) {
    _check(node.expression);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _check(node.condition);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    if (node.expression != null) {
      _check(node.expression!);
    }
  }
}

class _AssignmentVisitor extends RecursiveAstVisitor<void> {
  _AssignmentVisitor(this.rule);

  final AvoidAssignationInConditionRule rule;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    rule.reportAtNode(node);
  }
}
