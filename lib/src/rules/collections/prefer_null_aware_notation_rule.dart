import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferNullAwareNotationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_null_aware_notation',
    'Use null-aware notation (?.) instead of explicit null checks.',
    correctionMessage: '{0}.',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferNullAwareNotationRule()
    : super(
        name: 'prefer_null_aware_notation',
        description: 'Use null-aware notation (?.) instead of explicit null checks.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferNullAwareNotationRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node
        case BinaryExpression(
          leftOperand: final expr,
          operator: Token(type: final operatorType),
          rightOperand: BooleanLiteral(value: final rightValue),
        )
        when (operatorType == TokenType.EQ_EQ || operatorType == TokenType.BANG_EQ) &&
            (expr.staticType?.isNullable ?? false)) {
      final isCheckingTrue = rightValue;
      final message = 'Use ${isCheckingTrue ? '$expr ?? false' : '!($expr ?? false)'} instead of ${node.toSource()}.';

      rule.reportAtNode(node, arguments: [message]);
    }
  }
}
