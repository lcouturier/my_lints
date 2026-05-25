import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferNamedBooleanParametersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_named_boolean_parameters',
    'Converting positional boolean parameters to named parameters helps you avoid situations with a wrong value passed to the parameter.',
    correctionMessage: 'Try converting {0} boolean parameter to a named parameter.',
  );

  PreferNamedBooleanParametersRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _ParametersVisitor(this);
    registry.addFormalParameterList(this, visitor);
  }
}

class _ParametersVisitor extends SimpleAstVisitor<void> {
  final PreferNamedBooleanParametersRule rule;

  _ParametersVisitor(this.rule);

  @override
  void visitFormalParameterList(FormalParameterList node) {
    if (node.parent is MethodDeclaration) {
      if ((node.parent as MethodDeclaration).metadata.any((m) => m.name.name == 'override')) {
        return;
      }
    }
    for (final parameter in node.parameters.map((p) => p.unWrapped).whereType<SimpleFormalParameter>()) {
      final type = parameter.type;
      if (type?.type?.isDartCoreBool == true && parameter.isPositional) {
        rule.reportAtNode(parameter);
      }
    }
  }
}
