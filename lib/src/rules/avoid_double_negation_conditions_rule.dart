import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidDoubleNegationConditionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_double_negation_conditions',
    'Avoid double negation in conditions.',
    correctionMessage: 'Remove the double negation for better readability.',
  );

  AvoidDoubleNegationConditionsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addPrefixExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidDoubleNegationConditionsRule rule;

  _Visitor(this.rule);

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node.operator.type != TokenType.BANG) return;

    final operand = node.operand;
    final name = _extractName(operand);
    if (name != null && name.isNegativeName) {
      rule.reportAtNode(node);
    }
  }

  String? _extractName(Expression expression) {
    final current = expression.unParenthesized;

    return switch (current) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(identifier: final identifier) => identifier.name,
      PropertyAccess(propertyName: final propertyName) => propertyName.name,
      MethodInvocation(methodName: final methodName) => methodName.name,
      _ => null,
    };
  }
}
