// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports `context.read<T>()` or `context.select<T, R>()` calls
/// inside callbacks that may outlive the current widget build.
///
/// Reading a Cubit/Bloc through `context.read` inside a callback captures the
/// context at the time of the callback execution. If the widget is disposed
/// before the callback runs, the context is stale and the read will fail or
/// behave unexpectedly.
///
/// Prefer storing the cubit in a field during `initState` or retrieving it
/// once outside the callback.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return IconButton(
///       onPressed: () => context.read<CounterCubit>().increment(),
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
///   late final CounterCubit cubit;
///
///   @override
///   void initState() {
///     super.initState();
///     cubit = context.read<CounterCubit>();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return IconButton(
///       onPressed: cubit.increment,
///       icon: const Icon(Icons.add),
///     );
///   }
/// }
/// ```
class AvoidContextReadInCallbackRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_context_read_in_callback',
    'Avoid using context.read<T>() inside callbacks.',
    correctionMessage: 'Consider storing the cubit in a field during initState.',
  );

  AvoidContextReadInCallbackRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidContextReadInCallbackRule rule;

  _Visitor(this.rule);

  static const _callbackMethodNames = {
    'onPressed',
    'onLongPress',
    'onTap',
    'onChanged',
    'onSubmitted',
    'onToggle',
  };

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    if (_callbackMethodNames.contains(methodName)) {
      final arg = node.argumentList.arguments.firstOrNull;
      if (arg != null && _usesContextRead(arg)) {
        rule.reportAtNode(arg);
      }
    }
    super.visitMethodInvocation(node);
  }

  bool _usesContextRead(Expression expression) {
    final finder = _ContextReadFinder();
    expression.accept(finder);
    return finder.found;
  }
}

class _ContextReadFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (name == 'read' || name == 'select') {
      final target = node.realTarget;
      if (target is SimpleIdentifier && target.name == 'context') {
        found = true;
      }
    }
    super.visitMethodInvocation(node);
  }
}

extension on List<Expression> {
  Expression? get firstOrNull => isEmpty ? null : first;
}