import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A lint rule that encourages the use of spread operators (`...`) instead of
/// `addAll()` when adding collections to list/set/map literals.
///
/// Example:
/// ```dart
/// Bad
/// final list = [1, 2]..addAll([3, 4]);
/// final list2 = <int>[1, 2];
/// list2.addAll([3, 4]);
/// Good
/// final list = [1, 2, ...[3, 4]];
/// final list2 = [1, 2, ...[3, 4]];
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

extension on DartType {
  /// Returns true if the type is a list or set.
  ///
  /// This includes:
  /// - `Iterable`
  /// - `Set`
  /// - `List`
  /// - `Map`
  ///
  /// Note: `Map` is included because it can be spread in map literals.
  bool get isListOrSet => isDartCoreIterable || isDartCoreSet || isDartCoreList || isDartCoreMap;
}
