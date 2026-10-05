import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// Avoids unawaited futures in callbacks within Flutter widget classes.
/// This rule checks for unawaited futures in callback functions of Flutter widget classes and reports them.
/// Example:
/// ```dart
/// ElevatedButton(
///   onPressed: () {
///     someAsyncFunction(); // This will be reported if not awaited
///   },
/// )
/// ```
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
    // registry.addExpressionStatement(this, _Visitor(this));
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnawaitedFuturesInCallbacksRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterWidget) return;

    for (final member in node.members.whereType<MethodDeclaration>()) {
      final visitor = _ExpressionVisitor();
      member.accept(visitor);
      for (final unawaited in visitor.unawaitedFutures) {
        rule.reportAtNode(unawaited);
      }
    }
  }
}

class _ExpressionVisitor extends RecursiveAstVisitor<void> {
  List<ExpressionStatement> unawaitedFutures = [];

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final callback = node.thisOrAncestorOfType<FunctionExpression>();
    if (callback == null || !callback.isCallback) return;

    final returnType = node.expression.staticType;
    if (returnType is InterfaceType && returnType.isDartAsyncFuture) {
      unawaitedFutures.add(node);
    }
  }
}

extension on FunctionExpression {
  bool get isCallback {
    final parent = this.parent;
    if (parent is ArgumentList) return true;
    return parent is NamedExpression && parent.parent is ArgumentList;
  }
}
