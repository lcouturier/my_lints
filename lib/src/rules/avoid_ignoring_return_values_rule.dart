import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidIgnoringReturnValuesRule extends AnalysisRule {
  AvoidIgnoringReturnValuesRule() : super(name: code.name, description: code.problemMessage);

  static LintCode code = const LintCode(
    'avoid-ignoring-return-values',
    'Warns when a return value of a method or function invocation or a class instance property access is not used.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addExpressionStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidIgnoringReturnValuesRule rule;

  _Visitor(this.rule);
  @override
  void visitExpressionStatement(ExpressionStatement node) {
    if (node case ExpressionStatement(
      expression: MethodInvocation(staticType: final returnType),
    ) when returnType is! VoidType || (returnType is InterfaceType && returnType.isDartAsyncFuture)) {
      rule.reportAtNode(node);
      return;
    }

    if (node case ExpressionStatement(
      expression: FunctionExpressionInvocation(staticType: final returnType),
    ) when returnType is! VoidType || (returnType is InterfaceType && returnType.isDartAsyncFuture)) {
      rule.reportAtNode(node);
      return;
    }
  }
}
