import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports `Timer` fields not cancelled by a Flutter `State`.
///
/// Timer fields owned by a `State` must be cancelled synchronously in
/// `dispose()`, either directly or through a local helper method.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class ExampleState extends State<ExampleWidget> {
///   Timer? _timer;
///
///   @override
///   void dispose() {
///     super.dispose();
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class ExampleState extends State<ExampleWidget> {
///   Timer? _timer;
///
///   @override
///   void dispose() {
///     _timer?.cancel();
///     super.dispose();
///   }
/// }
/// ```
class AvoidUncancelledTimersInStateRule extends AnalysisRule {
  AvoidUncancelledTimersInStateRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'avoid_uncancelled_timers_in_state',
    'Timer "{0}" is not cancelled in dispose().',
    correctionMessage: 'Call cancel() on the timer in dispose().',
    severity: ErrorSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidUncancelledTimersInStateRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isFlutterWidget: true, :final timerFields) when timerFields.isNotEmpty) {
      final methods = {for (final method in node.members.whereType<MethodDeclaration>()) method.name.lexeme: method};
      final disposeMethod = methods['dispose'];

      final helperMethods = <String>{};
      final cancelled = <String>{};
      disposeMethod?.body.visitChildren(
        _CancellationVisitor(
          timerNames: timerFields.keys.map((e) => e.name ?? '').toSet(),
          onCancelled: (name) => cancelled.add(name),
          onHelperMethodCalled: (name) => helperMethods.add(name),
        ),
      );

      for (final helperMethod in helperMethods) {
        final m = methods[helperMethod];
        m?.body.visitChildren(
          _CancellationVisitor(
            timerNames: timerFields.keys.map((e) => e.name ?? '').toSet(),
            onCancelled: (name) => cancelled.add(name),
          ),
        );
      }

      for (final entry in timerFields.entries) {
        if (!cancelled.contains(entry.key.name)) {
          rule.reportAtToken(entry.value, arguments: [entry.key]);
        }
      }
    }
  }
}

class _CancellationVisitor extends RecursiveAstVisitor<void> {
  _CancellationVisitor({required this.timerNames, required this.onCancelled, this.onHelperMethodCalled});

  final Set<String> timerNames;
  final void Function(String) onCancelled;
  final void Function(String)? onHelperMethodCalled;

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'cancel'),
      realTarget: Expression(normalizedName: final targetName?),
    )) {
      if (timerNames.contains(targetName)) {
        onCancelled(targetName);
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
  /// Returns a map of timer field names to their corresponding tokens.
  /// The keys are the names of the timer fields, and the values are the tokens corresponding to those fields.
  Map<FieldElement, Token> get timerFields => {
    for (final variable in members.whereType<FieldDeclaration>().expand((field) => field.fields.variables))
      if (variable.declaredFragment?.element case final FieldElement element
          when element.type.isTimer && !element.isStatic)
        element: variable.name,
  };
}
