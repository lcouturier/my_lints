import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Lint rule that encourages avoiding spreading a single item in a collection literal.
/// For example, instead of writing:
/// ```dart/// var list = [...[a]];
/// ```
/// It suggests writing:
/// ```dart/// var list = [a];
/// ```
class AvoidRedundantSingleItemSpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_single_item_spread',
    'This spread contains a single item and can be removed.',
    correctionMessage: 'Use a direct assignment instead of spreading a single item.',
  );

  AvoidRedundantSingleItemSpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addSpreadElement(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidRedundantSingleItemSpreadRule rule;

  _Visitor(this.rule);

  @override
  void visitSpreadElement(SpreadElement node) {
    if (node case SpreadElement(
      expression: ListLiteral(:final elements) || SetOrMapLiteral(:final elements),
    ) when elements.length == 1 && elements.first is Expression) {
      if (elements.first is Literal || elements.first is SimpleIdentifier) {
        rule.reportAtNode(node);
      }
    }
  }
}
