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
/// // Good
/// var myMap = {...otherMap};
/// ```
class AvoidRedundantMapFromRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_map_from',
    'This Map.from is redundant. Try using a map literal with a spread operator instead.',
    correctionMessage: 'Try using a map literal with a spread operator instead.',
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

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'Map')), name: Identifier(name: 'from')),
      argumentList: ArgumentList(arguments: [Identifier()]),
    )) {
      rule.reportAtNode(node);
    }
  }
}
