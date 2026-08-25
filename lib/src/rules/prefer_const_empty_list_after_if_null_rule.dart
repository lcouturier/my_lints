import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Lint rule that encourages using a const empty list as an if-null fallback.
class PreferConstEmptyListAfterIfNullRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_const_empty_list_after_if_null',
    'Prefer a const empty list as the if-null fallback.',
    correctionMessage: 'Use const [] instead of [].',
  );

  PreferConstEmptyListAfterIfNullRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferConstEmptyListAfterIfNullRule rule;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      operator: Token(type: TokenType.QUESTION_QUESTION),
      rightOperand: ListLiteral(elements: [], constKeyword: null, typeArguments: null),
    )) {
      rule.reportAtNode(node);
    }
  }
}
