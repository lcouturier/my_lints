// ignore_for_file: unused_local_variable, unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule under development that reports some conditional map lookups.
///
/// It currently recognizes a conditional expression whose condition calls
/// `containsKey` and whose true branch indexes the same target with an
/// expression other than a simple identifier. It may produce false positives;
/// no general replacement is documented until the rule is complete.
///
/// ## Example
///
/// ⚠️ Currently reported:
/// ```dart
/// final result = map.containsKey(key) ? map[key.toString()] : fallback;
/// ```

class PreferTryGetValueRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_try_get_value',
    'Prefer using tryGetValue pattern instead of containsKey and []',
    correctionMessage:
        "Consider using tryGetValue instead of containsKey and [] for better performance and readability.",
  );

  PreferTryGetValueRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferTryGetValueRule rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node case ConditionalExpression(
      condition: MethodInvocation(
        :final target?,
        methodName: SimpleIdentifier(name: 'containsKey'),
        argumentList: ArgumentList(arguments: [final keyArg]),
      ),
      thenExpression: IndexExpression(target: final indexTarget?, index: final indexArg),
    )) {
      final targetName = target.unParenthesized.normalizedName;
      final indexTargetName = indexTarget.unParenthesized.normalizedName;
      final keyArgName = keyArg.unParenthesized.normalizedName;
      final indexArgName = indexArg.unParenthesized.normalizedName;
      if (targetName != null && targetName == indexTargetName && indexArgName == null) {
        rule.reportAtNode(node);
      }
    }
  }
}
