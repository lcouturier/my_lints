import 'dart:math';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';


/// A lint rule that detects complicated conditional expressions in if statements. It checks for the number of logical operators (&&, ||) and the nesting level of the conditions.
/// If an if statement contains 4 or more logical operators or has a nesting level of 3 or more, it is considered a complicated conditional and a lint warning is reported.
/// This rule encourages developers to simplify their conditional expressions to improve readability and maintainability of the code. Complex conditionals can be difficult to understand and can lead to bugs if not carefully managed.
class AvoidComplicatedConditionalRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_complicated_conditionals',
    'Avoid complicated conditionals.',
    correctionMessage: 'Consider simplifying the conditional expression to improve readability.',
  );

  AvoidComplicatedConditionalRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _IfVisitor(this));
  }
}


/// A visitor that checks for complicated conditional expressions in if statements. It visits each if statement and applies the _ComplexConditionVisitor to its condition expression.
/// The _ComplexConditionVisitor counts the number of logical operators and the nesting level of the conditions. If the number of logical operators is 4 or more, or if the nesting level is
/// 3 or more, it reports a lint warning at the location of the condition expression.
class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidComplicatedConditionalRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final visitor = _ComplexConditionVisitor();

  node.expression.accept(visitor);

  if (visitor.score > 5 && visitor.maxNesting >= 3) {
      rule.reportAtNode(node.expression);
    }
  }
}

/// A visitor that checks for complicated conditional expressions in binary expressions. It counts the number of logical operators (&&, ||) and the nesting level of the conditions.
/// It uses a recursive approach to traverse the binary expression tree and update the counts accordingly. The logicalOperators variable counts the number of logical operators, while the nesting variable tracks the current nesting level
/// and the maxNesting variable keeps track of the maximum nesting level encountered during the traversal.
class _ComplexConditionVisitor extends RecursiveAstVisitor<void> {
  int logicalOperators = 0;
  int nesting = 0;
  int maxNesting = 0;
  int score = 0;

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      score += 1;
    }

    super.visitPrefixExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;

    if (operator == TokenType.AMPERSAND_AMPERSAND ||
        operator == TokenType.BAR_BAR) {

      if (node.leftOperand is MethodInvocation || node.rightOperand is MethodInvocation) {
        score += 2;
      }

      score += 1;

      nesting++;
      maxNesting = max(maxNesting, nesting);

      super.visitBinaryExpression(node);

      nesting--;
      return;
    }

    super.visitBinaryExpression(node);
  }
}