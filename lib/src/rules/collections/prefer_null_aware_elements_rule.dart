import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferNullAwareElementsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_null_aware_elements',
    "Prefer null-aware elements ('...?') instead of checking for a potential null value.",
  );

  PreferNullAwareElementsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addIfElement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferNullAwareElementsRule rule;

  @override
  void visitIfElement(IfElement node) {
    if (node case IfElement(
      expression: BinaryExpression(
        leftOperand: SimpleIdentifier(name: final leftName),
        operator: Token(type: TokenType.BANG_EQ),
        rightOperand: NullLiteral(),
      ),
      thenElement: SimpleIdentifier(:final name),
    ) when leftName == name) {
      rule.reportAtNode(node);
    }
  }
}
