import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A spread element is considered redundant if it spreads an inline literal,
/// an empty literal, a single-item literal, or a nested spread.
/// For example:
/// ```dart
/// final list = [
///   ...[1, 2, 3], // Redundant spread of an inline literal.
///   ...[], // Redundant spread of an empty literal.
///   ...[42], // Redundant spread of a single-item literal.
///   ...[...[1, 2, 3]], // Redundant spread of a nested spread.
/// ];
/// ```
class AvoidRedundantSpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_spread',
    'Avoid redundant spread elements.',
    correctionMessage: 'Remove the unnecessary spread.',
  );

  AvoidRedundantSpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addSpreadElement(this, visitor)
      ..addListLiteral(this, visitor)
      ..addSetOrMapLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidRedundantSpreadRule rule;

  @override
  void visitListLiteral(ListLiteral node) {
    if (node case ListLiteral(elements: [SpreadElement()])) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (node case SetOrMapLiteral(elements: [SpreadElement()])) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    final expression = node.expression.unParenthesized;

    if (_isInlineLiteral(expression)) {
      rule.reportAtNode(node);
      return;
    }

    if (_isEmptyLiteral(expression)) {
      rule.reportAtNode(node);
      return;
    }

    if (_isSingleItemLiteral(expression)) {
      rule.reportAtNode(node);
      return;
    }

    if (_isNestedSpread(expression)) {
      rule.reportAtNode(node);
      return;
    }
  }
}

bool _isInlineLiteral(Expression expression) {
  return switch (expression) {
    ListLiteral() => true,
    SetOrMapLiteral() => true,
    _ => false,
  };
}

bool _isEmptyLiteral(Expression expression) {
  return switch (expression) {
    ListLiteral(elements: final elements) => elements.isEmpty,
    SetOrMapLiteral(elements: final elements) => elements.isEmpty,
    _ => false,
  };
}

bool _isSingleItemLiteral(Expression expression) {
  return switch (expression) {
    ListLiteral(elements: final elements) => elements.length == 1,
    SetOrMapLiteral(elements: final elements) => elements.length == 1,
    _ => false,
  };
}

bool _isNestedSpread(Expression expression) {
  return switch (expression) {
    ListLiteral(elements: final elements) => elements.length == 1 && elements.first is SpreadElement,
    SetOrMapLiteral(elements: final elements) => elements.length == 1 && elements.first is SpreadElement,
    _ => false,
  };
}
