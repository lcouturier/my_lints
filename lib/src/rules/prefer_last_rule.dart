import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferLastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_last_over_index',
    "Use '.last' instead of '.lastWhere' when you just want the last element.",
    correctionMessage: "Replace with '.last'.",
    severity: DiagnosticSeverity.WARNING,
  );

  PreferLastRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addMethodInvocation(this, visitor)
      ..addIndexExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferLastRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'elementAt'),
      argumentList: ArgumentList(
        arguments: [
          BinaryExpression(
            leftOperand: Identifier(name: final name),
            operator: Token(type: TokenType.MINUS),
            rightOperand: IntegerLiteral(value: 1),
          ),
        ],
      ),
    ) when name.contains('length')) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node case IndexExpression(
      index: BinaryExpression(
        leftOperand: Identifier(name: final name),
        operator: Token(type: TokenType.MINUS),
        rightOperand: IntegerLiteral(value: 1),
      ),
    ) when name.contains('length')) {
      rule.reportAtNode(node);
    }
  }
}
