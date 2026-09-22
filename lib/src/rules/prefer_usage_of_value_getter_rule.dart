import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferUsageOfValueGetterRule extends AnalysisRule {
  static const LintCode code = LintCode('prefer_usage_of_value_getter', 'Prefer using the value getter.');

  PreferUsageOfValueGetterRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addGenericFunctionType(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferUsageOfValueGetterRule rule;
  _Visitor(this.rule);

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    if (node case GenericFunctionType(
      typeParameters: null,
      parameters: FormalParameterList(parameters: []),
      returnType: final returnType,
    ) when returnType is NamedType && returnType.name.lexeme != 'void') {
      rule.reportAtNode(node);
    }
  }
}
