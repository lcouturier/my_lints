import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidExtensionsOnRecordsRule extends AnalysisRule {
  AvoidExtensionsOnRecordsRule() : super(name: code.name, description: code.problemMessage);

  static LintCode code = const LintCode(
    "avoid_extensions_on_records",
    "Creating an extension on a record type will make that extension available for every record with the same form (e.g. (String, String)), which can lead to unexpected results. Also, since extensions are used to add additional behavior to external objects, and the primary purpose of records is to group data (not behavior), it's recommended to create a dedicated class instead."
        "Avoid declaring extensions on record types. Try declaring a class instead.",
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addExtensionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidExtensionsOnRecordsRule rule;

  _Visitor(this.rule);

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    if (node case ExtensionDeclaration(onClause: ExtensionOnClause(extendedType: TypeAnnotation(type: RecordType())))) {
      rule.reportAtNode(node);
    }
  }
}
