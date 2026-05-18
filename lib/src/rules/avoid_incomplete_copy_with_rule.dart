// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidIncompleteCopyWithRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_incomplete_copy_with',
    'copyWith method is missing parameters',
    correctionMessage: 'Add missing parameters {0} to copyWith',
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
    final (found, copyWithMethod) = node.members.whereType<MethodDeclaration>().firstWhereOrNot(
      (m) => m.name.lexeme == 'copyWith',
    );
    if (!found) return;

    final fields = node.members
        .whereType<FieldDeclaration>()
        .map((e) => e.fields.variables.map((variable) => variable.name.lexeme).toList())
        .expand((f) => f)
        .toSet();
    if (fields.isEmpty) return;

    final body = copyWithMethod!.body.expression;
    if (body == null) return;

    final visitor = _CopyWithVisitor();
    body.accept(visitor);
    final assignedFields = visitor.fields;

    final missing = fields.difference(assignedFields);
    if (missing.isEmpty) return;

    rule.reportAtToken(copyWithMethod.name, arguments: [missing.join(', ')]);
  }
}

class _CopyWithVisitor extends RecursiveAstVisitor<void> {
  final Set<String> fields = {};

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node case NamedExpression(
      name: final label,
      expression: BinaryExpression(
        leftOperand: SimpleIdentifier(:final name),
        operator: Token(type: TokenType.QUESTION_QUESTION),
        rightOperand: PropertyAccess(
          target: ThisExpression(),
          operator: Token(type: TokenType.PERIOD),
          propertyName: SimpleIdentifier(name: final propertyName),
        ),
      ),
    ) when name == label.label.name && propertyName == label.label.name) {
      fields.add(label.label.name);
    }

    super.visitNamedExpression(node);
  }
}
