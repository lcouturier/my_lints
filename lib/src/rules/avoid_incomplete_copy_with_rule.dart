import 'dart:core';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidIncompleteCopyWithRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_incomplete_copy_with',
    'Avoid incomplete copyWith',
    correctionMessage: 'Add missing parameters {0} to copyWith',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidIncompleteCopyWithRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidIncompleteCopyWithRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isDataClass) return;

    final body = node.body;
    if (body is! BlockClassBody) return;

    final fields = body.members
        .whereType<FieldDeclaration>()
        .where((f) => f.fields.isFinal)
        .expand((f) => f.fields.variables)
        .map((v) => v.name.lexeme)
        .toSet();

    final copyWithMethod = body.members.whereType<MethodDeclaration>().firstWhereOrNull(
      (m) => m.name.lexeme == 'copyWith',
    );
    if (copyWithMethod == null) return;

    final copyWithParams =
        copyWithMethod.parameters?.parameters.map((e) => e.name?.lexeme).whereType<String>().toSet() ?? {};

    final missing = fields.difference(copyWithParams);

    rule.reportAtToken(copyWithMethod.name, arguments: [missing.join(', ')]);
  }
}
