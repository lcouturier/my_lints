import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidEnumValuesByIndexRule extends AnalysisRule {
  static const code = LintCode(
    'avoid_enum_values_by_index',
    'Avoid accessing enum values by index.',
    correctionMessage: 'Use the enum constant directly or byName() if using a string.',
  );

  AvoidEnumValuesByIndexRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIndexExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidEnumValuesByIndexRule rule;

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node case IndexExpression(
      index: IntegerLiteral(),
      target: PrefixedIdentifier(
        identifier: SimpleIdentifier(name: 'values'),
        prefix: SimpleIdentifier(element: Element()),
      ),
    )) {
      rule.reportAtNode(node);
    }
  }
}
