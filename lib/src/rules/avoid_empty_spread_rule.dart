import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

class AvoidEmptySpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_empty_spread',
    'This spread has no elements. Try adding elements or removing it.',
  );

  AvoidEmptySpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addSpreadElement(this, visitor);
  }
}

typedef _Result = ({bool found, Expression? expression});

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidEmptySpreadRule rule;

  _Visitor(this.rule);

  @override
  void visitSpreadElement(SpreadElement node) {
    if (node case SpreadElement(expression: ListLiteral(elements: final elements)) when elements.isEmpty) {
      rule.reportAtNode(node);
      return;
    }

    final v = _ParenthesizedExpressionVisitor();
    node.accept(v);
    final expr = v.expression;
    if (!expr.found) return;

    if (expr.expression! case ListLiteral(elements: final elements) when elements.isEmpty) {
      rule.reportAtNode(node);
    }
  }
}

class _ParenthesizedExpressionVisitor extends RecursiveAstVisitor<void> {
  _Result expression = (found: false, expression: null);

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    if (node.expression is! ParenthesizedExpression) {
      expression = (found: true, expression: node.expression);
    }
    super.visitParenthesizedExpression(node);
  }
}
