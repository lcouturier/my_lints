import 'dart:core';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidNestedSwitchExpressionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_switch_expression_rule',
    'Nested switch expressions can be difficult to read and maintain. Consider refactoring to avoid nesting.',
    correctionMessage: 'Try refactoring the code to avoid nested switch expressions.',
  );

  AvoidNestedSwitchExpressionRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addSwitchExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedSwitchExpressionRule rule;

  _Visitor(this.rule);

  @override
  void visitSwitchExpression(SwitchExpression node) {
    final result = node.cases.firstWhereOrNot((e) => e.expression is SwitchExpression);

    if (!result.$1) return;
    rule.reportAtNode(result.$2);
  }
}
