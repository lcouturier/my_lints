import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

/// A rule that reports tracked disposable fields not disposed in a widget's `dispose` method.
///
/// It tracks disposable fields declared on a Flutter widget class and disposable
/// instances assigned to those fields in `initState`. A `dispose` method must
/// exist for this rule to report undisposed fields.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyState extends State<MyWidget> {
///   final TextEditingController _controller = TextEditingController();
///   @override
///   void dispose() {
///     super.dispose();
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyState extends State<MyWidget> {
///   final TextEditingController _controller = TextEditingController();
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
///
class AvoidDisposableStateFieldLeaksRule extends AnalysisRule {
  AvoidDisposableStateFieldLeaksRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode('avoid_disposable_state_field_leaks', 'Controller "{0}" is not disposed.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidDisposableStateFieldLeaksRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isFlutterWidget: true, :final disposables) when disposables.isNotEmpty) {
      final disposeMethod = node.members.whereType<MethodDeclaration>().firstWhereOrNull(
        (method) => method.name.lexeme == 'dispose',
      );

      final helperMethods = <String>{};
      final cancelled = <String>{};
      disposeMethod?.body.visitChildren(
        _DisposeVisitor(
          disposes: disposables.keys.map((field) => field.name ?? '').toSet(),
          onDispose: (name) => cancelled.add(name),
          onHelperMethodCalled: (name) => helperMethods.add(name),
        ),
      );
      for (final helperMethod in helperMethods) {
        final m = node.members.whereType<MethodDeclaration>().firstWhereOrNull(
          (method) => method.name.lexeme == helperMethod,
        );
        m?.body.visitChildren(
          _DisposeVisitor(
            disposes: disposables.keys.map((field) => field.name ?? '').toSet(),
            onDispose: (name) => cancelled.add(name),
          ),
        );
      }

      for (final entry in disposables.entries) {
        if (!cancelled.contains(entry.key.name)) {
          rule.reportAtToken(entry.value, arguments: [entry.key.name ?? '']);
        }
      }
    }
  }
}

class _DisposeVisitor extends RecursiveAstVisitor<void> {
  final Set<String> disposes;
  final void Function(String) onDispose;
  final void Function(String)? onHelperMethodCalled;
  _DisposeVisitor({required this.disposes, required this.onDispose, this.onHelperMethodCalled});

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(methodName: SimpleIdentifier(name: 'dispose'), realTarget: final target?)) {
      if (target is! SuperExpression) {
        final name = target.getNormalizedName();
        if (name != null && disposes.contains(name)) {
          onDispose(name);
        }
      }
    } else {
      final name = node.methodName.name;
      if (name != 'dispose') {
        onHelperMethodCalled?.call(name);
      }
    }

    super.visitMethodInvocation(node);
  }
}

extension on ClassDeclaration {
  /// Returns a map of disposable fields to their name tokens.
  Map<FieldElement, Token> get disposables {
    final subscriptions = <FieldElement, Token>{};
    for (final variable in members.whereType<FieldDeclaration>().expand((e) => e.fields.variables)) {
      final element = variable.declaredFragment?.element;
      if (element is FieldElement && element.type.isDisposable) {
        subscriptions[element] = variable.name;
      }
    }
    return subscriptions;
  }
}
