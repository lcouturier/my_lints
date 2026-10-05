import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class PreferCorrectCallbackFieldNameRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_correct_callback_field_name',
    'Prefer correct callback field name',
    correctionMessage: 'Callback field name should start with "on": {0}',
  );

  PreferCorrectCallbackFieldNameRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferCorrectCallbackFieldNameRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!isWidget(node)) return;

    for (final member in node.members) {
      member.accept(this);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.fields.isFinal) return;

    final type = node.fields.type;
    if (type == null) return;

    if (!_isCallbackType(type)) return;

    for (final variable in node.fields.variables) {
      final name = variable.name.lexeme;
      if (name.startsWith('_')) continue;

      if (!name.startsWith('on')) {
        rule.reportAtToken(variable.name, arguments: [name]);
      }
    }
  }

  bool _isCallbackType(TypeAnnotation type) {
    if (type is GenericFunctionType) return true;

    final dartType = type.type;
    if (dartType == null) return false;

    if (dartType is FunctionType) return true;

    final alias = dartType.alias;
    return alias?.element.aliasedType is FunctionType;
  }

  bool isWidget(ClassDeclaration node) {
    final ext = node.extendsClause?.superclass.name.lexeme;
    return ext == 'StatelessWidget' || ext == 'StatefulWidget' || ext == 'Widget';
  }
}
