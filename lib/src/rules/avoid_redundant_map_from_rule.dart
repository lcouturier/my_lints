import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prevents redundant use of `Map.from` in Dart.
/// This rule detects cases where `Map.from` is used with a single argument that is an identifier, which is redundant and can be replaced with a map literal and a spread operator.
/// Example:
/// ```dart
/// // Bad
/// var myMap = Map.from(otherMap);
/// var myMap = Map.of(otherMap);
/// // Good
/// var myMap = {...otherMap};
/// ```
class AvoidRedundantMapFromRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_collection',
    'Redundant collection creation.',
    correctionMessage: 'Try using a collection literal with a spread operator instead.',
  );

  AvoidRedundantMapFromRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidRedundantMapFromRule rule;

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
