import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferNullAwareSpreadRule extends AnalysisRule {
  static final LintCode code = LintCode('prefer_null_aware_spread', 'Prefer null-aware spread operator.');

  PreferNullAwareSpreadRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addListLiteral(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferNullAwareSpreadRule rule;

  @override
  void visitListLiteral(ListLiteral node) {
    // ...localSet ?? {},
    for (var element in node.elements.whereType<SpreadElement>().where((e) => e.expression is BinaryExpression)) {
      if (element.expression case BinaryExpression(
        operator: Token(type: TokenType.QUESTION_QUESTION),
        rightOperand: TypedLiteral(),
      )) {
        rule.reportAtNode(element);
      }
    }

    // ...localSet != null ? localSet : <String>{},
    for (var element in node.elements.whereType<SpreadElement>().where((e) => e.expression is ConditionalExpression)) {
      if (element.expression case ConditionalExpression(
        condition: BinaryExpression(operator: Token(type: TokenType.BANG_EQ), rightOperand: NullLiteral()),
      )) {
        rule.reportAtNode(element);
      }
    }

    // if (localSet != null) ...localSet,
    for (var element in node.elements.whereType<IfElement>()) {
      if (element.expression case BinaryExpression(
        operator: Token(type: TokenType.BANG_EQ),
        leftOperand: SimpleIdentifier(name: final name),
        rightOperand: NullLiteral(),
      )) {
        if (element.thenElement case SpreadElement(expression: SimpleIdentifier())) {
          final then = ((element.thenElement as SpreadElement).expression as SimpleIdentifier);
          if (then.name == name) {
            rule.reportAtNode(element);
          }
        }
      }
    }
  }
}
