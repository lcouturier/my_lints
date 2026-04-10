import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferNullAwareSpreadRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_null_aware_spread',
    'a collection literal can be replaced with a null-aware spread (...?)',
  );

  PreferNullAwareSpreadRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addSpreadElement(this, visitor)
      ..addIfElement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferNullAwareSpreadRule rule;

  @override
  void visitIfElement(IfElement node) {
    // if (localSet != null) ...localSet
    if (node case IfElement(
      expression: BinaryExpression(
        leftOperand: SimpleIdentifier(),
        operator: Token(type: TokenType.BANG_EQ),
        rightOperand: NullLiteral(),
      ),
      thenElement: SpreadElement(),
    )) {
      rule.reportAtNode(node);
      return;
    }
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    // Spread avec ?? operator
    if (node case SpreadElement(expression: BinaryExpression(operator: Token(type: TokenType.QUESTION_QUESTION)))) {
      rule.reportAtNode(node);
      return;
    }

    // ...localSet != null ? localSet : <String>{}
    if (node case SpreadElement(
      expression: ConditionalExpression(
        condition: BinaryExpression(operator: Token(type: TokenType.BANG_EQ), rightOperand: NullLiteral()),
      ),
    )) {
      rule.reportAtNode(node);
      return;
    }
  }
}
