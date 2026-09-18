// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferMapOverMapIndexedRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_map_over_mapIndexed',
    "Prefer using map when the index is not used.",
    correctionMessage: "Use map instead of mapIndexed.",
  );

  PreferMapOverMapIndexedRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferMapOverMapIndexedRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'mapIndex' || 'mapIndexed'),
      argumentList: ArgumentList(arguments: [final FunctionExpression functionExpr]),
      target: Expression(staticType: final targetType?),
    ) when iterableChecker.isAssignableFromType(targetType)) {
      final index =
          (node.methodName.name == 'mapIndexed'
                  ? functionExpr.parameters?.parameters.first
                  : functionExpr.parameters?.parameters[1])
              as SimpleFormalParameter;

      final indexName = index.name?.lexeme;
      if (indexName == null) return;
      if (indexName == '_') {
        rule.reportAtNode(node.methodName);
        return;
      }

      final indexElement = index.declaredFragment?.element;
      if (indexElement == null) {
        return;
      }

      final body = functionExpr.body;
      var found = false;
      final visitor = _ElementSearchVisitor(indexElement, onFound: () => found = true);
      body.accept(visitor);
      if (found) return;

      rule.reportAtNode(node.methodName);
    }
  }
}

class _ElementSearchVisitor extends RecursiveAstVisitor<void> {
  final FormalParameterElement target;
  final void Function() onFound;

  _ElementSearchVisitor(this.target, {required this.onFound});

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element == target) {
      onFound();
    }

    super.visitSimpleIdentifier(node);
  }
}
