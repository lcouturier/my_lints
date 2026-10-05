import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferFunctionTypedefsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_function_typedefs',
    'Prefer function typedefs',
    correctionMessage: 'Use a typedef instead of an inline function type.',
  );

  PreferFunctionTypedefsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addFormalParameterList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferFunctionTypedefsRule rule;

  _Visitor(this.rule);

  @override
  void visitFormalParameterList(FormalParameterList node) {
    for (final parameter in node.parameters.map((p) => p.unWrapped).whereType<SimpleFormalParameter>()) {
      final type = parameter.type;
      if (type is GenericFunctionType) {
        rule.reportAtNode(type);
      }
    }
  }
}
