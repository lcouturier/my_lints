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
      leftOperand: final left,
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: final right,
    )) {
      if (_isLengthAccess(left) && _isZeroLiteral(right)) {
        rule.reportAtNode(node, arguments: ['length', '==']);
      }
    }
  }

  bool _isZeroLiteral(Expression expr) {
    return expr is IntegerLiteral && expr.value == 0;
  }

  /// list.length → PrefixedIdentifier
  /// this.list.length → PropertyAccess
  /// (foo.bar).length → PropertyAccess
  bool _isLengthAccess(Expression expr) {
    return switch (expr) {
      PropertyAccess(propertyName: SimpleIdentifier(name: 'length')) => true,
      PrefixedIdentifier(identifier: SimpleIdentifier(name: 'length')) => true,
      _ => false,
    };
  }
}
