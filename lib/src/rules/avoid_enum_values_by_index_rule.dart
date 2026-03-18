import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidEnumValuesByIndexRule extends AnalysisRule {
  static final code = LintCode(
    'avoid_enum_values_by_index',
    'Avoid accessing enum values by index.',
    correctionMessage: 'Use the enum constant directly or byName() if using a string.',
  );

  AvoidEnumValuesByIndexRule() : super(name: code.lowerCaseName, description: code.problemMessage);

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
    final target = node.target;
    if (target is PrefixedIdentifier && target.identifier.name == 'values' && node.index is IntegerLiteral) {
      if (target.prefix.element is EnumElement) {
        rule.reportAtNode(node);
      }
    }
  }
}
