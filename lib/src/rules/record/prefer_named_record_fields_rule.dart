import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart' show RuleVisitorRegistry;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferNamedRecordFieldsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_named_record_fields',
    'Record fields should be named for better readability.',
    correctionMessage: 'Consider adding names to record fields.',
  );

  PreferNamedRecordFieldsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addRecordTypeAnnotation(this, visitor)
      ..addRecordLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferNamedRecordFieldsRule rule;

  @override
  void visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    final positional = node.positionalFields;
    final named = node.namedFields;

    if (named?.fields.isNotEmpty ?? false) return;
    if (positional.length < 2) return;

    final allSimple = positional.every((e) => _isSimpleType(e.type));
    if (!allSimple) return;

    // rule.reportAtNode(node);
  }

  bool _isSimpleType(TypeAnnotation type) {
    return type is NamedType && type.typeArguments == null && type.question == null;
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    for (final field in node.fields) {
      if (field is! NamedExpression) {
        rule.reportAtNode(node);
        return;
      }
    }

    // final positional = node.fields.positionalFields;
    // final named = node.fields.namedFields;

    // if (named?.fields.isNotEmpty ?? false) return;
    // if (positional.length < 2) return;

    // final allSimple = node.fields.every((e) => _isSimpleType(e.));
    // if (!allSimple) return;

    rule.reportAtNode(node);
  }
}
