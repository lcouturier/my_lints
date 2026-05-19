import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedRecordRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_record',
    'Avoid using nested records.',
    correctionMessage: 'Extract the inner record into a variable or use a dedicated class.',
  );

  AvoidNestedRecordRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addRecordLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedRecordRule rule;

  _Visitor(this.rule);

  @override
  void visitRecordLiteral(RecordLiteral node) {
    for (final field in node.fields) {
      final expression = _fieldExpression(field);
      if (_isNestedRecord(expression)) {
        rule.reportAtNode(expression);
      }
    }
  }

  Expression _fieldExpression(Expression field) {
    if (field is NamedExpression) {
      return field.expression;
    }
    return field;
  }

  bool _isNestedRecord(Expression expression) {
    final unwrapped = expression.unParenthesized;
    if (unwrapped is RecordLiteral) {
      return true;
    }
    return unwrapped.staticType is RecordType;
  }
}
