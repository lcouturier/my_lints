import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';

class PreferThrowExceptionOrErrorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_throw_exception_or_error',
    'Avoid throwing literals or raw Exception/Error. Use a specific Exception or Error type instead.',
  );

  PreferThrowExceptionOrErrorRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addThrowExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferThrowExceptionOrErrorRule rule;

  _Visitor(this.rule);

  @override
  void visitThrowExpression(ThrowExpression node) {
    if (node case ThrowExpression(
      expression: InstanceCreationExpression(
        constructorName: ConstructorName(name: SimpleIdentifier(name: 'Exception')),
        argumentList: ArgumentList(arguments: [Literal()]),
      ),
    )) {
      rule.reportAtNode(node);
    }
  }
}

extension on InterfaceType {
  bool get isCoreExceptionOrError =>
      (element.name == 'Exception' || element.name == 'Error') && element.library.isDartCore;
  // ignore: unused_element
  bool get isExceptionOrError {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((t) {
      return t.isCoreExceptionOrError;
    });
  }
}
