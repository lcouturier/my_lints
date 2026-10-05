import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

@Deprecated('Do not use')
class NoBooleanLiteralCompareRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_boolean_literal_compare',
    'Comparing boolean values to boolean literals is unnecessary, as those expressions will result in booleans too. Just use the boolean values directly or negate them.',
    correctionMessage: 'Remove the unnecessary comparison to boolean literals.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoBooleanLiteralCompareRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final NoBooleanLiteralCompareRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type != TokenType.EQ_EQ && node.operator.type != TokenType.BANG_EQ) return;

    if ((node.leftOperand is BooleanLiteral && isBoolType(node.rightOperand.staticType)) ||
        (node.rightOperand is BooleanLiteral && isBoolType(node.leftOperand.staticType))) {
      rule.reportAtNode(node);
    }
  }

  bool isNullableType(DartType? type) => type?.nullabilitySuffix == NullabilitySuffix.question;
  bool isBoolType(DartType? type) => type != null && type.isDartCoreBool && !isNullableType(type);
}
