import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// A rule that prevents empty spreads in Dart collections.
/// This rule detects cases where a spread operator is used with an empty collection,
/// which is redundant and can be removed.
/// https://dcm.dev/docs/rules/common/avoid-empty-spread/
class AvoidEmptySpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_empty_spread',
    'This spread has no elements. Try adding elements or removing it.',
    correctionMessage: 'Try adding elements or removing the spread.',
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

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidEmptySpreadRule rule;

  _Visitor(this.rule);

  @override
  void visitSpreadElement(SpreadElement node) {
    final expression = _unwrapParentheses(node.expression);

    if (expression case ListLiteral(elements: final elements) when elements.isEmpty) {
      rule.reportAtNode(node);
    }
  }

  /// Unwrap all nested parentheses to get the actual expression.
  Expression _unwrapParentheses(Expression expr) {
    var current = expr;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }
}
