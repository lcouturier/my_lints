import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidComplicatedConditionalRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_complicated_conditionals',
    'Avoid complicated conditionals.',
    correctionMessage: 'Consider splitting the condition into smaller expressions.',
  );

  AvoidComplicatedConditionalRule({required this.threshold}) : super(name: code.name, description: code.problemMessage);

  final int threshold;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _IfVisitor(this);
    registry
      ..addIfStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addDoStatement(this, visitor);
  }
}

class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidComplicatedConditionalRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    _verify(node.expression);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _verify(node.condition);
  }

  void _verify(Expression condition) {
    int operatorCount = 0;
    int methodCallCount = 0;
    int negationCount = 0;

    condition.accept(
      _SimpleConditionVisitor(
        onOperator: () => operatorCount++,
        onMethodCall: () => methodCallCount++,
        onNegation: () => negationCount++,
      ),
    );

    final isTooComplex = operatorCount + methodCallCount + negationCount >= rule.threshold;

    if (isTooComplex) {
      rule.reportAtNode(condition);
    }
  }
}

class _SimpleConditionVisitor extends RecursiveAstVisitor<void> {
  final void Function() onOperator;
  final void Function() onMethodCall;
  final void Function() onNegation;

  _SimpleConditionVisitor({required this.onOperator, required this.onMethodCall, required this.onNegation});

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final op = node.operator.type;

    if (op == TokenType.AMPERSAND_AMPERSAND || op == TokenType.BAR_BAR) {
      onOperator();
    }

    super.visitBinaryExpression(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    onOperator(); // ternary adds a branch
    super.visitConditionalExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      onNegation();
    }

    super.visitPrefixExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    onMethodCall();
    super.visitMethodInvocation(node);
  }
}
