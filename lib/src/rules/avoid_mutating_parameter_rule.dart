import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidMutatingParametersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_mutating_parameters',
    "a parameter's field or setter is reassigned.",
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidMutatingParametersRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidMutatingParametersRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final parameters = node.parameters?.parameters
        .map((e) => e.declaredFragment?.element)
        .whereType<FormalParameterElement>()
        .toSet();
    if (parameters?.isEmpty ?? true) return;

    node.body.accept(_MutationVisitor(parameters!, rule));
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final parameters = node.functionExpression.parameters?.parameters
        .map((e) => e.declaredFragment?.element)
        .whereType<FormalParameterElement>()
        .toSet();
    if (parameters?.isEmpty ?? true) return;

    node.functionExpression.body.accept(_MutationVisitor(parameters!, rule));
  }
}

class _MutationVisitor extends RecursiveAstVisitor<void> {
  _MutationVisitor(this.parameters, this.rule);

  final Set<FormalParameterElement> parameters;
  final AvoidMutatingParametersRule rule;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node case AssignmentExpression(
      leftHandSide: SimpleIdentifier(element: final element),
    ) when parameters.contains(element)) {
      rule.reportAtNode(node);
    }

    super.visitAssignmentExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node case PrefixExpression(
      operator: Token(type: TokenType.PLUS_PLUS) || Token(type: TokenType.MINUS_MINUS),
      operand: SimpleIdentifier(element: final element),
    ) when parameters.contains(element)) {
      rule.reportAtNode(node);
    }
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node case PostfixExpression(
      operator: Token(type: TokenType.PLUS_PLUS) || Token(type: TokenType.MINUS_MINUS),
      operand: SimpleIdentifier(element: final element),
    ) when parameters.contains(element)) {
      rule.reportAtNode(node);
    }
    super.visitPostfixExpression(node);
  }
}
