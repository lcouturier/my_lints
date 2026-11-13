// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports the use of `context` inside callbacks that may outlive
/// the current widget build.
///
/// Callbacks such as `onPressed`, `onChanged`, or `Future.then` can execute
/// after the widget has been disposed, making the captured `context` stale.
/// This can lead to crashes or unexpected behavior when the stale context is
/// used to show dialogs, navigate, or access inherited widgets.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return IconButton(
///       onPressed: () => Scaffold.of(context).showBottomSheet(...),
///       icon: const Icon(Icons.add),
///     );
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   @override
///   Widget build(BuildContext context) {
///     return IconButton(
///       onPressed: () {
///         if (!mounted) return;
///         Scaffold.of(context).showBottomSheet(...);
///       },
///       icon: const Icon(Icons.add),
///     );
///   }
/// }
/// ```
class AvoidContextInCallbackRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_context_in_callback',
    'Avoid using context inside callbacks that may outlive the widget.',
    correctionMessage: 'Consider checking mounted or using a GlobalKey before using context.',
  );

  AvoidContextInCallbackRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidContextInCallbackRule rule;

  _Visitor(this.rule);

  static const _callbackMethodNames = {
    'onPressed',
    'onLongPress',
    'onTap',
    'onChanged',
    'onSubmitted',
    'onChanged',
    'onToggle',
    'onChanged',
  };

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    if (_callbackMethodNames.contains(methodName)) {
      final arg = node.argumentList.arguments.firstOrNull;
      if (arg != null && _usesContext(arg)) {
        rule.reportAtNode(arg);
      }
    }
    super.visitMethodInvocation(node);
  }

  bool _usesContext(Expression expression) {
    final finder = _ContextFinder();
    expression.accept(finder);
    return finder.found;
  }
}

class _ContextFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'context') {
      found = true;
    }
    super.visitSimpleIdentifier(node);
  }
}

extension on List<Expression> {
  Expression? get firstOrNull => isEmpty ? null : first;
}