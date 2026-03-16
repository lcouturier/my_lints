import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidSelfAssignmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_self_assignment',
    'Avoid self-assignment.',
    correctionMessage: 'Remove the self-assignment.',
  );

  AvoidSelfAssignmentRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addAssignmentExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidSelfAssignmentRule rule;

  _Visitor(this.rule);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.operator.type != TokenType.EQ) return;
    if (node.leftHandSide.toString() != node.rightHandSide.toString()) return;

    rule.reportAtNode(node);
  }
}
