import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that checks for complex loop conditions in `for` statements.
/// Complex loop conditions can make code harder to read and understand. This rule encourages developers to extract complex conditions into separate variables or methods for better readability.
/// example:
/// ```dart
/// for (int i = 0; i < items.length && items[i].isValid(); i++) {
///   // do something
/// }
/// ```
/// This loop condition is complex because it combines multiple conditions using the logical AND operator. A better approach would be to extract the condition into a separate variable or method, like so:
/// ```dart
/// bool isValidItem(int index) {
///   return index < items.length && items[index].isValid();
/// }
/// for (int i = 0; isValidItem(i); i++) {
///   // do something
/// }
class AvoidComplexLoopConditionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_complex_loop_conditions',
    'Avoid complex loop conditions. Extract the condition to a variable or method.',
  );

  AvoidComplexLoopConditionsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addForStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidComplexLoopConditionsRule rule;

  @override
  void visitForStatement(ForStatement node) {
    if (node case ForStatement(
      forLoopParts: final forLoopParts,
    ) when forLoopParts is ForPartsWithExpression || forLoopParts is ForPartsWithDeclarations) {
      final condition = _getCondition(forLoopParts);
      if (condition != null && _isComplex(condition)) {
        rule.reportAtNode(condition);
      }
    }
  }

  Expression? _getCondition(ForLoopParts forLoopParts) {
    return switch (forLoopParts) {
      ForPartsWithExpression() => forLoopParts.condition,
      ForPartsWithDeclarations() => forLoopParts.condition,
      _ => null,
    };
  }

  bool _isComplex(Expression condition) {
    final visitor = _ComplexConditionVisitor();
    condition.accept(visitor);
    return visitor.isComplex;
  }
}

class _ComplexConditionVisitor extends RecursiveAstVisitor<void> {
  bool isComplex = false;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (isComplex) return;

    final type = node.operator.type;

    if (type == TokenType.AMPERSAND_AMPERSAND || type == TokenType.BAR_BAR) {
      isComplex = true;
      return;
    }

    super.visitBinaryExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    isComplex = true;
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    isComplex = true;
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (isComplex) return;
    super.visitPrefixExpression(node);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    if (isComplex) return;
    super.visitParenthesizedExpression(node);
  }
}
