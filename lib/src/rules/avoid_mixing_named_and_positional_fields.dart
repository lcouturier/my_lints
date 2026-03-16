import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidMixingNamedAndPositionalFields extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_mixing_named_and_positional_fields',
    'Avoid mixing named and positional fields',
    correctionMessage: 'Avoid mixing named and positional fields',
  );

  AvoidMixingNamedAndPositionalFields()
    : super(name: 'avoid_mixing_named_and_positional_fields', description: 'Avoid mixing named and positional fields');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addRecordLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidMixingNamedAndPositionalFields rule;

  _Visitor(this.rule);

  @override
  void visitRecordLiteral(RecordLiteral node) {
    bool isMixed = node.fields.any((e) => e is NamedExpression) && node.fields.any((e) => e is! NamedExpression);
    if (!isMixed) return;

    rule.reportAtNode(node);
  }
}
