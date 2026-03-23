import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidNullableListReturnTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nullable_list_return_type',
    'Avoid nullable list return type',
    correctionMessage: 'Avoid nullable list return type',
  );

  AvoidNullableListReturnTypeRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _ListVisitor(this);
    registry.addNamedType(this, visitor);
  }
}

class _ListVisitor extends SimpleAstVisitor<void> {
  final AvoidNullableListReturnTypeRule rule;

  _ListVisitor(this.rule);

  @override
  void visitNamedType(NamedType node) {
    if (node case NamedType(element: Element(name: 'List'), question: _?)) {
      rule.reportAtNode(node);
    }
  }
}
