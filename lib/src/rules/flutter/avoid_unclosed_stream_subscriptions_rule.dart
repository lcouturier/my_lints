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

/// A rule that reports stream subscriptions in a Flutter `State` that are not cancelled.
///
/// This rule checks fields typed as `StreamSubscription` (including subtypes)
/// and requires a direct `cancel()` call in the state's `dispose` method.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class ExampleState extends State<ExampleWidget> {
///   late final StreamSubscription<int> _subscription;
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
///   late final StreamSubscription<int> _subscription;
///
///   @override
///   void dispose() {
///     _subscription.cancel();
///     super.dispose();
///   }
/// }
/// ```
class AvoidUnclosedStreamSubscriptionsRule extends AnalysisRule {
  AvoidUnclosedStreamSubscriptionsRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'avoid_unclosed_stream_subscriptions',
    'Stream subscription "{0}" is not cancelled in dispose().',
    correctionMessage: 'Call cancel() on the subscription in dispose().',
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
  final AvoidUnclosedStreamSubscriptionsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(
      isFlutterWidget: true,
      :final streamSubscriptions,
    ) when streamSubscriptions.isNotEmpty) {
      final disposeMethod = node.members.whereType<MethodDeclaration>().firstWhereOrNull(
        (method) => method.name.lexeme == 'dispose',
      );

      /// je crée une liste vide de helper mthodes pour le moment, mais je pourrais ajouter des helpers plus tard
      /// qui va être alimentée par le _CancelVisitor
      final cancelled = <String>{};
      disposeMethod?.body.visitChildren(
        _CancelVisitor(streamSubscriptions.keys.map((field) => field.name ?? '').toSet(), cancelled),
      );

      /// chaque méthode de la liste de helpers sera visitée pas _CancelVisitor

      for (final entry in streamSubscriptions.entries) {
        if (!cancelled.contains(entry.key.name)) {
          rule.reportAtToken(entry.value, arguments: [entry.key.name ?? '']);
        }
      }
    }
  }
}

class _CancelVisitor extends RecursiveAstVisitor<void> {
  final Set<String> subscriptions;
  final Set<String> cancelled;

  _CancelVisitor(this.subscriptions, this.cancelled);

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(methodName: SimpleIdentifier(name: 'cancel'), realTarget: final target?)) {
      final name = target.getNormalizedName();
      if (name != null && subscriptions.contains(name)) {
        cancelled.add(name);
      }
    }

    super.visitMethodInvocation(node);
  }
}

extension on ClassDeclaration {
  /// Returns a map of stream subscription fields to their name tokens.
  Map<FieldElement, Token> get streamSubscriptions {
    final subscriptions = <FieldElement, Token>{};
    for (final variable in members.whereType<FieldDeclaration>().expand((e) => e.fields.variables)) {
      final element = variable.declaredFragment?.element;
      if (element is FieldElement && element.type.isStreamSubscription) {
        subscriptions[element] = variable.name;
      }
    }
    return subscriptions;
  }
}
