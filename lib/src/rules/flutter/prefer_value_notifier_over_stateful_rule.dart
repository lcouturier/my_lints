import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports simple StatefulWidget that could be replaced with ValueNotifier.
///
/// This rule detects StatefulWidget with a single mutable field and simple state
/// management that could be simplified using ValueNotifier. ValueNotifier is
/// lighter weight and avoids the overhead of StatefulWidget lifecycle.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class CounterWidget extends StatefulWidget {
///   @override
///   State<CounterWidget> createState() => _CounterWidgetState();
/// }
///
/// class _CounterWidgetState extends State<CounterWidget> {
///   int _count = 0;
///
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       onPressed: () => setState(() => _count++),
///       child: Text('$_count'),
///     );
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class CounterWidget extends StatelessWidget {
///   final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);
///
///   @override
///   Widget build(BuildContext context) {
///     return ValueListenableBuilder<int>(
///       valueListenable: countNotifier,
///       builder: (context, count, child) {
///         return ElevatedButton(
///           onPressed: () => countNotifier.value++,
///           child: Text('$count'),
///         );
///       },
///     );
///   }
/// }
/// ```
class PreferValueNotifierOverStatefulRule extends AnalysisRule {
  PreferValueNotifierOverStatefulRule() : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'prefer_value_notifier_over_stateful',
    'Simple StatefulWidget can be replaced with ValueNotifier.',
    correctionMessage: 'Consider using ValueNotifier for simple state management.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferValueNotifierOverStatefulRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final type = node.extendsClause?.superclass.type;
    if (type == null || type is! InterfaceType) return;
    if (type.element.name != 'StatefulWidget') return;

    final stateClass = _findStateClass(node);
    if (stateClass == null) return;

    if (_isSimpleStatefulWidget(stateClass)) {
      rule.reportAtToken(node.name);
    }
  }

  ClassDeclaration? _findStateClass(ClassDeclaration widgetClass) {
    final compilationUnit = widgetClass.parent;
    if (compilationUnit is! CompilationUnit) return null;

    for (final declaration in compilationUnit.declarations) {
      if (declaration is! ClassDeclaration) continue;

      final type = declaration.extendsClause?.superclass.type;
      if (type == null || type is! InterfaceType) continue;
      if (type.element.name != 'State') continue;

      return declaration;
    }

    return null;
  }

  bool _isSimpleStatefulWidget(ClassDeclaration stateClass) {
    final type = stateClass.extendsClause?.superclass.type;
    if (type == null || type is! InterfaceType) return false;
    if (type.element.name != 'State') return false;
    if (!type.isFlutterState) return false;

    final mutableFields = stateClass.members
        .whereType<FieldDeclaration>()
        .where((f) => !f.isStatic && !f.fields.isFinal)
        .toList();

    if (mutableFields.length != 1) return false;

    final hasComplexLifecycle = _hasComplexLifecycleMethods(stateClass);
    if (hasComplexLifecycle) return false;

    final setStateCount = _countSetStateCalls(stateClass);
    if (setStateCount != 1) return false;

    return true;
  }

  int _countSetStateCalls(ClassDeclaration stateClass) {
    final visitor = _SetStateCounter();
    stateClass.accept(visitor);
    return visitor.count;
  }

  bool _hasComplexLifecycleMethods(ClassDeclaration stateClass) {
    final methods = stateClass.members.whereType<MethodDeclaration>();
    final lifecycleMethods = ['initState', 'dispose', 'didChangeDependencies'];

    for (final method in methods) {
      if (lifecycleMethods.contains(method.name.lexeme)) {
        return true;
      }
    }

    return false;
  }
}

class _SetStateCounter extends RecursiveAstVisitor<void> {
  int count = 0;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState') {
      count++;
    }
    super.visitMethodInvocation(node);
  }
}
