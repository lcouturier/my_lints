import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports stream subscriptions that are not stored or cancelled.
///
/// This rule detects calls to `listen()` on streams where the resulting
/// `StreamSubscription` is not assigned to a variable. Unchecked subscriptions
/// can lead to memory leaks because they cannot be cancelled later.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
/// stream.listen((data) { print(data); });
/// ```
///
/// ✅ Good:
/// ```dart
/// final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
/// final subscription = stream.listen((data) { print(data); });
/// subscription.cancel();
/// ```
class AvoidUncheckedStreamSubscriptionsRule extends AnalysisRule {
  AvoidUncheckedStreamSubscriptionsRule() : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'avoid_unchecked_stream_subscriptions',
    'Stream subscription is not stored or cancelled.',
    correctionMessage: 'Store the subscription in a variable so it can be cancelled later.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUncheckedStreamSubscriptionsRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(methodName: Identifier(name: 'listen'))) {
      final parent = node.parent;
      if (parent is AssignmentExpression && parent.leftHandSide == node) {
        return;
      }

      if (parent is VariableDeclaration && parent.initializer == node) {
        return;
      }

      if (parent is ExpressionStatement) {
        final returnType = node.staticType;
        if (returnType is InterfaceType && returnType.getDisplayString().contains('StreamSubscription')) {
          rule.reportAtNode(node);
        }
      }
    }
  }
}
