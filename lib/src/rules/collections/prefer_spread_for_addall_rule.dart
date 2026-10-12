import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports `addAll` calls with one argument on collection targets.
///
/// When building a collection literal, use a spread element to include another
/// collection's elements.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final values = <int>[1, 2]..addAll([3, 4]);
/// ```
///
/// ✅ Good:
/// ```dart
/// final values = <int>[1, 2, ...[3, 4]];
/// ```
class PreferSpreadForAddallRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_spread_for_addAll',
    'Use spread operator (...) instead of addAll().',
    correctionMessage: 'Replace addAll() with spread operator.',
  );

  PreferSpreadForAddallRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferSpreadForAddallRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: "addAll"),
      argumentList: ArgumentList(arguments: [final _]),
      target: Expression(staticType: DartType(isListOrSet: true)),
    )) {
      rule.reportAtNode(node);
    }
  }
}
