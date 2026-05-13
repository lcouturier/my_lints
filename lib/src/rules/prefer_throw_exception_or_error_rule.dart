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
    if (node case ThrowExpression(expression: Literal())) {
      rule.reportAtNode(node);
      return;
    }

    if (node case ThrowExpression(expression: Expression(staticType: final type)) when type is InterfaceType) {
      if (type.isCoreExceptionOrError) {
        rule.reportAtNode(node);
        return;
      }
      if (!type.isExceptionOrError) {
        rule.reportAtNode(node);
        return;
      }
    }
  }
}

extension on InterfaceType {
  bool get isCoreExceptionOrError =>
      (element.name == 'Exception' || element.name == 'Error') && element.library.isDartCore;
  bool get isExceptionOrError {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((t) {
      return t.isCoreExceptionOrError;
    });
  }
}
