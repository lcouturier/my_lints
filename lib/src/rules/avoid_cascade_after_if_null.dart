import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidCascadeAfterIfNull extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_cascade_after_if_null',
    'Avoid using cascade operator after if-null operator.',
    correctionMessage: 'Add parentheses around the cascade expression.',
  );

  AvoidCascadeAfterIfNull() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addCascadeExpression(this, visitor)
      ..addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidCascadeAfterIfNull rule;

  _Visitor(this.rule);

  @override
  void visitCascadeExpression(CascadeExpression node) {
    if (node case CascadeExpression(target: final target)) {
      if (target is ParenthesizedExpression) return;
      if (target is BinaryExpression &&
          target.operator.type == TokenType.QUESTION_QUESTION &&
          target.rightOperand is ParenthesizedExpression)
        return;
      rule.reportAtNode(node);
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      operator: Token(type: TokenType.QUESTION_QUESTION),
      rightOperand: CascadeExpression(),
    )) {
      rule.reportAtNode(node);
    }
  }
}
