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
    for (var element in node.elements.whereType<SpreadElement>().where((e) => e.expression is BinaryExpression)) {
      final binary = element.expression as BinaryExpression;
      if (binary.rightOperand is TypedLiteral) {
        if (binary.operator.type == TokenType.QUESTION_QUESTION) {
          rule.reportAtNode(element);
        }
      }
    }

    for (var element in node.elements.whereType<SpreadElement>().where((e) => e.expression is ConditionalExpression)) {
      final conditional = element.expression as ConditionalExpression;
      if (conditional.condition is BinaryExpression) {
        final binary = conditional.condition as BinaryExpression;

        if ((binary.operator.type == TokenType.BANG_EQ) && (binary.rightOperand is NullLiteral)) {
          rule.reportAtNode(element);
        }
      }
    }

    for (var element in node.elements.whereType<IfElement>()) {
      if ((element.expression is BinaryExpression) && (element.thenElement is SpreadElement)) {
        final binary = element.expression as BinaryExpression;
        final left = binary.leftOperand as SimpleIdentifier;
        if ((element.thenElement as SpreadElement).expression is! SimpleIdentifier) {
          return;
        }
        final then = ((element.thenElement as SpreadElement).expression as SimpleIdentifier);
        if (left.name != then.name) return;
        if ((binary.operator.type == TokenType.BANG_EQ) && (binary.rightOperand is NullLiteral)) {
          rule.reportAtNode(element);
        }
      }
    }
  }
}
