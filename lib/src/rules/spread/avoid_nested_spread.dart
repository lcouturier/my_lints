// final list = [
//   ...[
//     ...other,
//   ],
// ];

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedSpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_spread',
    'Avoid using nested spread operators.',
    correctionMessage: 'Remove the nested spread operator.',
  );

  AvoidNestedSpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addSpreadElement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidNestedSpreadRule rule;

  @override
  void visitSpreadElement(SpreadElement node) {
    // ...[...[other]]
    if (node.expression case ListLiteral(elements: [SpreadElement()])) {
      rule.reportAtNode(node);
    }
  }
}
