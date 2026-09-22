import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Lint rule that encourages using if elements instead of ternary expressions for spread operations.
/// For example, instead of writing:
/// ```dart
/// var list = [...(condition ? [a] : [])];
/// ```
/// It suggests writing:
/// ```dart/// var list = [
///   if (condition) a,
/// ];
/// ```
@Deprecated('Use PreferCollectionIfForConditionalElementsRule instead, which covers this case and more.')
class PreferIfElementsToTernarySpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_if_elements_to_ternary_spread',
    'Prefer using if elements instead of ternary expressions for spread operations.',
    correctionMessage: 'Use if elements instead of ternary expressions for spread operations.',
  );

  PreferIfElementsToTernarySpreadRule() : super(name: code.name, description: code.problemMessage);

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

  final PreferIfElementsToTernarySpreadRule rule;

  @override
  void visitSpreadElement(SpreadElement node) {
    // ...(condition ? [a] : [])
    if (node case SpreadElement(
      expression: ParenthesizedExpression(
        expression: ConditionalExpression(
          thenExpression: ListLiteral(elements: final elements),
          elseExpression: ListLiteral(elements: []),
        ),
      ),
    ) when elements.length == 1) {
      rule.reportAtNode(node);
    }
  }
}
