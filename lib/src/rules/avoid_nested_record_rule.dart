


import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedRecordRule extends AnalysisRule {
  static final LintCode code = LintCode(
    'avoid_nested_record_rule',
    'Avoid using nested records.',
  );

  AvoidNestedRecordRule()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
      registry.addVariableDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedRecordRule rule;

  _Visitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final initializer = node.initializer;
    if (initializer is! RecordLiteral) return;

    for (final field in initializer.fields) {
      if (field.staticType?.toString().startsWith('(') ?? false) {
        rule.reportAtNode(field);
      }
    }
  }
}