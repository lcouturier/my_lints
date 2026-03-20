import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferContainsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_contains',
    'Use .contains() instead of .indexOf() compared to -1.',
    correctionMessage: 'Replace with .contains() for better readability.',
  );

  PreferContainsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferContainsRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final op = node.operator.type;
    if (op != TokenType.EQ_EQ && op != TokenType.BANG_EQ) return;

    final left = node.leftOperand;
    final right = node.rightOperand;

    if (left.isIndexOfCall && right.isNegativeOne) {
      rule.reportAtNode(node);
      return;
    }

    if (left.isNegativeOne && right.isIndexOfCall) {
      rule.reportAtNode(node);
    }
  }
}
