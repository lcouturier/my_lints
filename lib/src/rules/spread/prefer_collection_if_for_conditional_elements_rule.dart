// ignore_for_file: unused_local_variable

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports single-element list spreads guarded by `if` or a conditional expression.
///
/// Use an `if` collection element directly instead of spreading a one-element
/// list.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final values = [if (condition) ...[value]];
/// ```
///
/// ✅ Good:
/// ```dart
/// final values = [if (condition) value];
/// ```
class PreferCollectionIfForConditionalElementsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_collection_if_for_conditional_elements',
    'Avoid unnecessary spreads or ternaries in collections.',
  );

  PreferCollectionIfForConditionalElementsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addListLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferCollectionIfForConditionalElementsRule rule;

  @override
  void visitListLiteral(ListLiteral node) {
    for (final element in node.elements) {
      if (element case IfElement(
        thenElement: SpreadElement(expression: ListLiteral(elements: final thenElements)),
      ) when thenElements.length == 1) {
        rule.reportAtNode(element);
        return;
      }

      if (element case SpreadElement(expression: ParenthesizedExpression(expression: ConditionalExpression()))) {
        _checkExpression(element.expression.unParenthesized as ConditionalExpression);
      }
      if (element case SpreadElement(expression: ConditionalExpression())) {
        _checkExpression(element.expression as ConditionalExpression);
      }

      // Case 2: ternary producing list
      // (condition ? [a] : [])
      if (element case ParenthesizedExpression(expression: ConditionalExpression())) {
        _checkExpression(element.expression as ConditionalExpression);
      }
      // (condition ? [a] : [])
      if (element case ConditionalExpression()) {
        _checkExpression(element);
      }
    }
  }

  void _checkExpression(ConditionalExpression expression) {
    if (expression case ConditionalExpression(
      thenExpression: ListLiteral(elements: final thenElements),
      elseExpression: ListLiteral(elements: []),
    ) when thenElements.length == 1) {
      rule.reportAtNode(expression);
      return;
    }
  }
}
