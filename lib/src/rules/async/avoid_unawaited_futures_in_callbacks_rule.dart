import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports unawaited futures in callbacks declared in widget classes.
///
/// This rule detects expression statements that return a `Future` inside a
/// callback in a method of a Flutter widget class. Await the future or handle it
/// explicitly so asynchronous work is not accidentally discarded.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class SaveButton extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) => ElevatedButton(
///     onPressed: () {
///       save();
///     },
///     child: const Text('Save'),
///   );
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class SaveButton extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) => ElevatedButton(
///     onPressed: () async {
///       await save();
///     },
///     child: const Text('Save'),
///   );
/// }
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
