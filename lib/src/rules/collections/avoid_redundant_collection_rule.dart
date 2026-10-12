import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports `List`, `Set`, or `Map` `from`/`of` constructors given one identifier.
///
/// Use a collection spread to copy the source into a collection literal.
/// The rule only recognizes a single identifier argument; it does not report
/// other constructor forms such as `Map.fromIterable`.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final source = <String, int>{'a': 1};
/// final copy = Map<String, int>.from(source);
/// ```
///
/// ✅ Good:
/// ```dart
/// final source = <String, int>{'a': 1};
/// final copy = <String, int>{...source};
/// ```
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
