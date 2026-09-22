import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

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
    final visitor = _ConditionHostVisitor(this);
    registry
      ..addIfStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addDoStatement(this, visitor)
      ..addForStatement(this, visitor)
      ..addConditionalExpression(this, visitor);
  }
}

class _ConditionHostVisitor extends SimpleAstVisitor<void> {
  final AvoidYodaConditionsRule rule;

  _ConditionHostVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    node.expression.accept(_ConditionVisitor(rule));
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    node.condition.accept(_ConditionVisitor(rule));
  }

  @override
  void visitDoStatement(DoStatement node) {
    node.condition.accept(_ConditionVisitor(rule));
  }

  @override
  void visitForStatement(ForStatement node) {
    final forLoopParts = node.forLoopParts;
    final condition = switch (forLoopParts) {
      ForPartsWithExpression() => forLoopParts.condition,
      ForPartsWithDeclarations() => forLoopParts.condition,
      _ => null,
    };

    condition?.accept(_ConditionVisitor(rule));
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    node.condition.accept(_ConditionVisitor(rule));
  }
}

class _ConditionVisitor extends RecursiveAstVisitor<void> {
  final AvoidYodaConditionsRule rule;

  _ConditionVisitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    if (!node.operator.type.isComparisonOperator) return;
    if ((node.leftOperand.isConstant) && (!node.rightOperand.isConstant)) {
      rule.reportAtNode(node);
    }
  }
}
