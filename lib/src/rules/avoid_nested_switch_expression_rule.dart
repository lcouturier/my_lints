import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidNestedSwitchExpressionRule extends AnalysisRule {
  static final LintCode code = LintCode(
    'avoid_nested_switch_expression_rule',
    'Avoid using nested switch expressions.',
    severity: DiagnosticSeverity.WARNING,
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
    final (found, expr) = node.cases.firstWhereOrNot((e) => e.expression is SwitchExpression);

    if (!found) return;
    rule.reportAtNode(expr);
  }
}
