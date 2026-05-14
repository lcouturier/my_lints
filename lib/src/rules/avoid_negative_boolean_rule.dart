import 'dart:math';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNegativeBooleanRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_negative_boolean',
    'Avoid negative boolean names.',
    correctionMessage: 'Use a positive boolean name to improve readability.',
  );

  AvoidNegativeBooleanRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry
      ..addPrefixExpression(this, _Visitor(this))
      ..addVariableDeclaration(this, _Visitor(this))
      ..addFormalParameterList(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNegativeBooleanRule rule;

  static const _negativePatterns = ['not', 'no', 'disable', 'disabled', 'cannot', 'cant', 'without'];

  _Visitor(this.rule);

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node case PrefixExpression(operator: Token(type: TokenType.BANG), operand: Identifier(:final name))) {
      _checkName(name, node);
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final parent = node.parent;
    if (parent is! VariableDeclarationList) return;

    if (parent.type?.type?.isDartCoreBool ?? false) {
      _checkName(node.name.lexeme, node);
    }
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    for (final param in node.parameters.whereType<SimpleFormalParameter>()) {
      if (param.type?.type?.isDartCoreBool ?? false) {
        _checkName(param.name?.lexeme ?? '', param);
      }
    }
  }

  void _checkName(String name, AstNode node) {
    final lower = name.toLowerCase();

    for (final pattern in _negativePatterns) {
      if (lower.contains(pattern)) {
        rule.reportAtNode(node);
        return;
      }
    }
  }
}
