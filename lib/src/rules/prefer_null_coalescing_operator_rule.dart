import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// In progress: This rule is not fully implemented yet and may produce false positives. Use with caution.
/// detect patterns like `x != null ? x : defaultValue` and suggest using `x ?? defaultValue` instead.
class PreferNullCoalescingOperatorRule extends AnalysisRule {
  PreferNullCoalescingOperatorRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'prefer_null_coalescing_operator',
    'Use the null coalescing operator (??) instead of the ternary operator for null checks.',
    correctionMessage: 'Consider using the null coalescing operator (??) instead.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferNullCoalescingOperatorRule rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node case ConditionalExpression(
      condition: BinaryExpression(
        leftOperand: SimpleIdentifier(name: final leftName),
        operator: Token(type: TokenType.BANG_EQ),
        rightOperand: NullLiteral(),
      ),
      thenExpression: SimpleIdentifier(name: final thenName),
    ) when leftName == thenName) {
      rule.reportAtNode(node);
    }

    super.visitConditionalExpression(node);
  }
}
