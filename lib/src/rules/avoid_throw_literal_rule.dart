import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart' show ThrowExpression, Literal;
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidThrowLiteralRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_throw_literal',
    'Avoid throwing literals.',
    correctionMessage: 'Throw an Exception or Error instead of a literal.',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidThrowLiteralRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addThrowExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidThrowLiteralRule rule;

  _Visitor(this.rule);

  @override
  void visitThrowExpression(ThrowExpression node) {
    if (node.expression is Literal) {
      rule.reportAtNode(node);
    }
  }
}
