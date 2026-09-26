import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferIsEmptyRule extends AnalysisRule {
  PreferIsEmptyRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'prefer_is_empty',
    'Prefer using isEmpty instead of length',
    correctionMessage: "Prefer using `.isEmpty` over `.length == 0 or Prefer using `.isNotEmpty` over `.length != 0`.",
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferIsEmptyRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      leftOperand: (PropertyAccess(propertyName: SimpleIdentifier(name: 'length')) ||
          PrefixedIdentifier(identifier: SimpleIdentifier(name: 'length'))),
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    )) {
      rule.reportAtNode(node, arguments: ['length', '==']);
    }
  }
}
