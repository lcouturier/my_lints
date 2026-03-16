import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidMultiAssignmentRule extends AnalysisRule {
  static final LintCode code = LintCode(
    'avoid_multi_assignment',
    'Avoid multiple assignments on the same line.',
    correctionMessage: 'Avoid multiple assignments on the same line.',
  );

  AvoidMultiAssignmentRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addAssignmentExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidMultiAssignmentRule rule;

  _Visitor(this.rule);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.operator.type != TokenType.EQ) return;
    if (node.rightHandSide is! AssignmentExpression) return;

    rule.reportAtNode(node);
  }
}
