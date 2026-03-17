import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidPositionalRecordFieldAccessRule extends AnalysisRule {
  static final LintCode code = LintCode(
    'avoid_positional_record_field_access',
    'Avoid positional record field access',
    correctionMessage: 'Avoid positional record field access',
  );

  AvoidPositionalRecordFieldAccessRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addPropertyAccess(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidPositionalRecordFieldAccessRule rule;

  _Visitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      propertyName: SimpleIdentifier(name: final propertyName),
      realTarget: SimpleIdentifier(staticType: RecordType()),
    )) {
      if (propertyName.startsWith(r'$')) {
        rule.reportAtNode(node);
      }
    }
  }
}
