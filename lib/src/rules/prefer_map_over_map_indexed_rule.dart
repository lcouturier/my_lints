import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class PreferMapOverMapIndexedRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_map_over_mapIndexed',
    "Prefer using map when the index is unused.",
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
    if (node.methodName.name != 'mapIndexed') {
      return;
    }

    final callback = node.argumentList.arguments.firstOrNull;
    if (callback is! FunctionExpression) {
      return;
    }

    final parameters = callback.parameters?.parameters;
    if (parameters == null || parameters.length < 2) {
      return;
    }

    final indexParameter = parameters.first;
    if (indexParameter is! SimpleFormalParameter) {
      return;
    }

    final indexElement = indexParameter.declaredFragment?.element;
    if (indexElement == null) {
      return;
    }

    final isUsed = _usesParameter(callback.body, indexElement);

    if (!isUsed) {
      rule.reportAtNode(indexParameter);
    }
  }

  bool _usesParameter(AstNode node, FormalParameterElement parameter) {
    var found = false;
    node.visitChildren(_IdentifierSearchVisitor(parameter, onFound: () => found = true));
    return found;
  }
}

class _IdentifierSearchVisitor extends RecursiveAstVisitor<void> {
  final FormalParameterElement target;
  final void Function() onFound;

  _IdentifierSearchVisitor(this.target, {required this.onFound});

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element == target) {
      onFound();
    }
  }
}
