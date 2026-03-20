import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferLastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_last_over_index',
    "Use '.last' instead of '.lastWhere' when you just want the last element.",
    correctionMessage: "Replace with '.last'.",
    severity: DiagnosticSeverity.WARNING,
  );

  PreferLastRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addMethodInvocation(this, visitor)
      ..addIndexExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferLastRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.realTarget;
    if (node.methodName.name == 'elementAt') {
      final arg = node.argumentList.arguments.first;

      if (arg is BinaryExpression && isLastElementAccess(arg, target.toString())) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    final target = node.realTarget;

    final index = node.index;

    if (index is BinaryExpression && isLastElementAccess(index, target.toString())) {
      rule.reportAtNode(node);
    }
  }
}
