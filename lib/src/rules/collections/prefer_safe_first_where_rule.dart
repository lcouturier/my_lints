import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that recommends an `orElse` callback for where-method calls.
///
/// This rule reports `firstWhere`, `lastWhere`, and `singleWhere` calls without
/// a named `orElse` argument when the target's static type is `Iterable`,
/// `List`, `Set`, or `Map`. Without `orElse`, these methods throw a
/// `StateError` when no element matches. `singleWhere` also throws when more
/// than one element matches.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final result = values.firstWhere((value) => value == 42);
/// ```
///
/// ✅ Good:
/// ```dart
/// final result = values.firstWhere((value) => value == 42, orElse: () => 0);
/// ```
///
/// See also:
/// - [List.firstWhere](https://api.dart.dev/stable/dart-core/List/firstWhere.html)
/// - [List.lastWhere](https://api.dart.dev/stable/dart-core/List/lastWhere.html)
/// - [List.singleWhere](https://api.dart.dev/stable/dart-core/List/singleWhere.html)
class PreferSafeFirstWhereRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_safe_first_where',
    'firstWhere(), lastWhere() and singleWhere() find the first or only element matching a condition, respectively. Both methods throw a StateError if no element matches, and singleWhere() throws an error if more than one element matches.',
    correctionMessage: 'Use the optional orElse parameter to provide a default if no element matches.',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferSafeFirstWhereRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const _methods = ['firstWhere', 'singleWhere', 'lastWhere'];

  _Visitor(this.rule);

  final PreferSafeFirstWhereRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      isListOrSetTarget: true,
      methodName: SimpleIdentifier(name: final methodName),
      hasElseParameter: false,
    ) when _methods.contains(methodName)) {
      rule.reportAtNode(node);
    }
  }
}

extension on MethodInvocation {
  bool get isListOrSetTarget => target?.staticType?.isListOrSet ?? false;
  bool get hasElseParameter =>
      argumentList.arguments.any((arg) => arg is NamedExpression && arg.name.label.name == 'orElse');
}
