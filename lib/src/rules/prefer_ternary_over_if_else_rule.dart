import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferTernaryOverIfElseRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_ternary_over_if_else',
    "Use a ternary operator instead of an if-else statement.",
    correctionMessage: "Try using a ternary operator instead of an if-else statement.",
  );

  PreferTernaryOverIfElseRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferTernaryOverIfElseRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final thenReturn = _extractReturn(node.thenStatement);
    final elseReturn = _extractReturn(node.elseStatement);
    if (thenReturn == null || elseReturn == null) {
      return;
    }
    final thenExpression = thenReturn.expression?.unParenthesized;
    final elseExpression = elseReturn.expression?.unParenthesized;
    if (thenExpression == null || elseExpression == null) {
      return;
    }
    if (!_isSimpleExpression(thenExpression) || !_isSimpleExpression(elseExpression)) {
      return;
    }
    rule.reportAtNode(node);
  }

  ReturnStatement? _extractReturn(Statement? statement) {
    return switch (statement) {
      ReturnStatement() => statement,
      Block(statements: [final ReturnStatement returnStmt]) => returnStmt,
      _ => null,
    };
  }

  bool _isSimpleExpression(Expression expression) {
    return [
      expression is Literal,
      expression is SimpleIdentifier,
      expression is PrefixedIdentifier,
      expression is PropertyAccess,
    ].any((e) => e);
  }

  
}
