import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

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
    final visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferNamedBooleanParametersRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node case MethodDeclaration(:final parameters) when parameters != null) {
      final boolParams = parameters.parameters.whereType<SimpleFormalParameter>().where(
        (p) => (p.type?.type?.isDartCoreBool ?? false),
      );
      if (boolParams.length > 1) {
        for (final p in boolParams.where((p) => !p.isNamed)) {
          rule.reportAtNode(p, arguments: [p.name?.lexeme ?? '']);
        }
      }
    }
  }
}
