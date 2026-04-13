import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidCascadeAfterIfNullRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_cascade_after_if_null',
    'Avoid using cascade operator after if-null operator.',
    correctionMessage: 'Add parentheses around the cascade expression.',
  );

  AvoidCascadeAfterIfNullRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addCascadeExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidCascadeAfterIfNullRule rule;

  _Visitor(this.rule);

  @override
  void visitCascadeExpression(CascadeExpression node) {
    if (node case CascadeExpression(target: BinaryExpression(operator: Token(type: TokenType.QUESTION_QUESTION)))) {
      rule.reportAtNode(node);
    }
  }
}
