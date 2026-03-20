import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidNestedIfRule extends AnalysisRule {
  static final LintCode code = LintCode('avoid_nested_if', 'Avoid nested if statements.');

  AvoidNestedIfRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedIfRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final depth = node.depth((node) => node is IfStatement);
    if (depth > 3) {
      rule.reportAtNode(node);
    }
  }
}
