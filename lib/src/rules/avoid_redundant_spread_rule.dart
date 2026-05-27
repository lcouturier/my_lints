// final list = [
//   ...list,
// ];

// final set = {
//   ...set,
// };

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidRedundantSpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_spread',
    "Avoid using spread operator on collections that are already being spread.",
    correctionMessage: "Remove the redundant spread operator.",
  );

  AvoidRedundantSpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addListLiteral(this, visitor)
      ..addSetOrMapLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidRedundantSpreadRule rule;

  _Visitor(this.rule);

  @override
  void visitListLiteral(ListLiteral node) {
    _checkForRedundantSpread(node.elements);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _checkForRedundantSpread(node.elements);
  }

  void _checkForRedundantSpread(NodeList<CollectionElement> elements) {
    if (elements.length == 1 && elements.first is SpreadElement) {
      rule.reportAtNode(elements.first);
    }
    // for (final element in elements) {
    //   if (element is SpreadElement && element.expression is SpreadElement) {
    //     rule.reportAtNode(element);
    //   }
    // }
  }
}
