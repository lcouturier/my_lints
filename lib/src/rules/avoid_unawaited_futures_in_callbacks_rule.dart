import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidUnawaitedFuturesInCallbacksRule extends AnalysisRule {
  AvoidUnawaitedFuturesInCallbacksRule() : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'avoid_unawaited_futures_in_callbacks',
    'Avoid unawaited futures in callbacks.',
    correctionMessage: 'Consider awaiting the future or handling it appropriately.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addExpressionStatement(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnawaitedFuturesInCallbacksRule rule;

  _Visitor(this.rule);

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final callback = node.thisOrAncestorOfType<FunctionExpression>();
    if (callback == null || !callback.isFlutterWidgetCallback) return;

    final returnType = node.expression.staticType;
    if (returnType is InterfaceType && returnType.isDartAsyncFuture) {
      rule.reportAtNode(node);
    }
  }
}

extension on FunctionExpression {
  bool get isFlutterWidgetCallback {
    final argumentList = switch (parent) {
      ArgumentList() => parent,
      NamedExpression(parent: final ArgumentList argumentList) => argumentList,
      _ => null,
    };
    final widget = argumentList?.parent;
    if (widget is! InstanceCreationExpression) return false;

    final widgetType = widget.staticType;
    return widgetType != null && widgetChecker.isAssignableFromType(widgetType);
  }
}
