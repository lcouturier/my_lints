import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferAdditionSubtractionAssignmentsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_addition_subtraction_assignments',
    'Prefer using += and -= instead of ++ and --',
  );

  PreferAdditionSubtractionAssignmentsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addPostfixExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferAdditionSubtractionAssignmentsRule rule;

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node case PostfixExpression(
      parent: final parent?,
      operator: Token(type: TokenType.PLUS_PLUS) || Token(type: TokenType.MINUS_MINUS),
    ) when parent is! ForPartsWithDeclarations && parent is! ForPartsWithExpression) {
      rule.reportAtNode(node);
    }
  }
}

class PreferCompoundAssignmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_compound_assignment',
    'Prefer using compound assignment operators (e.g., +=, -=) instead of simple assignment with arithmetic operations.',
  );

  PreferCompoundAssignmentRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _CompoundAssignmentVisitor(this);
    registry.addAssignmentExpression(this, visitor);
  }
}

class _CompoundAssignmentVisitor extends SimpleAstVisitor<void> {
  _CompoundAssignmentVisitor(this.rule);

  final PreferCompoundAssignmentRule rule;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node case AssignmentExpression(
      leftHandSide: final left,
      operator: Token(type: TokenType.EQ),
      rightHandSide: BinaryExpression(
        leftOperand: final leftOperand,
        operator: Token(type: TokenType.PLUS) ||
            Token(type: TokenType.MINUS) ||
            Token(type: TokenType.SLASH) ||
            Token(type: TokenType.STAR),
      ),
    ) when left is SimpleIdentifier && leftOperand is SimpleIdentifier && left.name == leftOperand.name) {
      rule.reportAtNode(node);
    }
  }
}
