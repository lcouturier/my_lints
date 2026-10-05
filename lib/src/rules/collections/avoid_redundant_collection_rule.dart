import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Avoid creating a collection from an other collection.
///
/// Example:
/// ```dart
/// // Bad
/// var otherMap = {'key': 'value'};
/// var myMap = Map.from(otherMap);
/// // Good
/// var myMap = {...otherMap};
/// ```
///
/// This lint also triggers for:
/// - `List.from(otherList)` -> `[...otherList]`
/// - `Set.from(otherSet)` -> `{...otherSet}`
///
/// This rule does not trigger for:
/// - `Map.fromIterable()`
/// - `Map.fromIterable(..., key: (e) => e.key, value: (e) => e.value)`
/// - `Map.fromIterable(..., value: (e) => e)`
/// - `List.from([1, 2])` (if there's no clear other collection to spread)
///
/// The main idea is to avoid `Map.from(otherMap)` and favor `Map.fromIterable()` when it's possible, or even just a map literal with spread operators ` {...otherMap}`.
///
///
class AvoidRedundantCollectionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_collection',
    'Redundant collection creation.',
    correctionMessage: 'Try using a collection literal with a spread operator instead.',
  );

  AvoidRedundantCollectionRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidRedundantCollectionRule rule;

  _Visitor(this.rule);

  static const _targetTypes = {'List', 'Set', 'Map'};
  static const _targetConstructors = {'from', 'of'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: final type)), name: Identifier(:final name)),
      argumentList: ArgumentList(arguments: [Identifier()]),
    ) when _targetTypes.contains(type) && _targetConstructors.contains(name)) {
      rule.reportAtNode(node);
    }
  }
}
