import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedRecordRule extends AnalysisRule {
  static final LintCode code = LintCode('avoid_nested_record_rule', 'Avoid using nested records.');

  AvoidNestedRecordRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addVariableDeclaration(this, visitor)
      ..addSimpleIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedRecordRule rule;

  final Set<String> _recordVariables = {};

  _Visitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final initializer = node.initializer;

    if (initializer is RecordLiteral) {
      _recordVariables.add(node.name.lexeme);

      _checkRecordLiteral(initializer);
    }
  }

  void _checkRecordLiteral(RecordLiteral record) {
    for (final field in record.fields) {
      if (field is RecordLiteral) {
        rule.reportAtNode(field); // Report direct du record imbriqué
      } else if (field is SimpleIdentifier && _recordVariables.contains(field.name)) {
        rule.reportAtNode(field); // Report si référence à variable contenant record
      }
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // Si la variable est connue comme record, report
    if (_recordVariables.contains(node.name)) {
      rule.reportAtNode(node);
    }
  }
}
