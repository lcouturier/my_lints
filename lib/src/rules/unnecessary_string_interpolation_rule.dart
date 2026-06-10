// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart' show RuleContext;
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class UnnecessaryStringInterpolationRule extends AnalysisRule {
  static const code = LintCode(
    'unnecessary_string_interpolation',
    'Unnecessary string interpolation.',
    correctionMessage: 'Remove unnecessary interpolation braces.',
  );

  UnnecessaryStringInterpolationRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInterpolationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static final List<bool Function(AstNode)> _matchers = [
    (node) => node is SimpleIdentifier,
    (node) => node is StringLiteral,
    (node) => node is IntegerLiteral,
    (node) => node is DoubleLiteral,
    (node) => node is BooleanLiteral,
    (node) => node is NullLiteral,
  ];

  final UnnecessaryStringInterpolationRule rule;

  _Visitor(this.rule);

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    if (node.leftBracket.type != TokenType.STRING_INTERPOLATION_EXPRESSION) {
      return;
    }

    final expression = node.expression.unParenthesized;

    if (!_matchers.any((e) => e(expression))) {
      return;
    }

    if (!_canRemoveBraces(node)) {
      return;
    }

    rule.reportAtNode(node);
  }

  bool _canRemoveBraces(InterpolationExpression node) {
    final parent = node.parent;

    if (parent is! StringInterpolation) {
      return false;
    }

    final elements = parent.elements;
    final index = elements.indexOf(node);

    if (index == elements.length - 1) {
      return true;
    }

    final next = elements[index + 1];
    if (next is! InterpolationString) {
      return false;
    }

    final value = next.value;
    return value.isEmpty;
  }
}
