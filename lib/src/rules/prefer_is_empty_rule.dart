import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferIsEmptyRule extends AnalysisRule {
  PreferIsEmptyRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  static final LintCode code = LintCode(
    'prefer_is_empty',
    'Prefer using isEmpty instead of length',
    correctionMessage: "Prefer using `.isEmpty` over `.length == 0 or Prefer using `.isNotEmpty` over `.length != 0`.",
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addVariableDeclaration(this, visitor)
      ..addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferIsEmptyRule rule;

  _Visitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node.initializer case BinaryExpression(
      leftOperand: PropertyAccess(propertyName: SimpleIdentifier(name: 'length')),
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    )) {
      rule.reportAtNode(node.initializer!, arguments: ['length', '==']);
    }
  }

  @override
  void visitIfStatement(IfStatement node) {
    if (node.expression case BinaryExpression(
      leftOperand: PrefixedIdentifier(identifier: SimpleIdentifier(name: 'length')),
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    )) {
      rule.reportAtNode(node.expression, arguments: ['length', '==']);
    }
  }
}
