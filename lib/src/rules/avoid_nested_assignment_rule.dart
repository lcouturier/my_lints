import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedAssignmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_assignment',
    'Nested assignments can lead to confusion or indicate an incorrect operator (= instead of ==).',
    correctionMessage: 'Try moving each assignment to its own line.',
  );

  AvoidNestedAssignmentRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addAssignmentExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedAssignmentRule rule;

  _Visitor(this.rule);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node case AssignmentExpression(operator: Token(type: TokenType.EQ), rightHandSide: AssignmentExpression())) {
      rule.reportAtNode(node);
    }
  }
}
