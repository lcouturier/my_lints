import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidAlwaysNullParametersRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'avoid_always_null_parameters',
    'Avoid always null parameters.',
    correctionMessage: 'Consider using a non-nullable type or a default value.',
  );

  AvoidAlwaysNullParametersRule() : super(name: code.name, description: code.problemMessage);

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

class _Visitor extends SimpleAstVisitor {
  final AvoidAlwaysNullParametersRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkDeclaration(node, node.declaredFragment?.element);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme == 'copyWith') {
      return;
    }
    _checkDeclaration(node, node.declaredFragment?.element);
  }

  void _checkDeclaration(AstNode node, Element? element) {
    if (element is! ExecutableElement) {
      return;
    }

    final nullableParameters = element.formalParameters.where((parameter) => parameter.type.isNullable).toList();
    if (nullableParameters.isEmpty) {
      return;
    }

    final collector = _InvocationCollector(element);
    node.root.accept(collector);
    for (final parameter in nullableParameters) {
      final isEverFed = collector.invocations.any((invocation) {
        final argument = _argumentForParameter(invocation, element, parameter);
        return argument != null && argument is! NullLiteral;
      });
      if (!isEverFed) {
        rule.reportAtNode(_parameterNode(node, parameter));
      }
    }
  }

  AstNode _parameterNode(AstNode node, FormalParameterElement parameter) {
    final declaration = node as Declaration;
    final parameters = switch (declaration) {
      FunctionDeclaration(:final functionExpression) => functionExpression.parameters,
      MethodDeclaration(:final parameters) => parameters,
      _ => null,
    };
    return parameters?.parameters
            .map((formalParameter) => formalParameter.unWrapped)
            .firstWhere((formalParameter) => formalParameter.declaredFragment?.element == parameter) ??
        node;
  }

  Expression? _argumentForParameter(AstNode node, ExecutableElement element, FormalParameterElement parameter) {
    final argumentList = switch (node) {
      FunctionExpressionInvocation(:final argumentList) => argumentList,
      MethodInvocation(:final argumentList) => argumentList,
      _ => null,
    };
    if (argumentList == null) {
      return null;
    }

    if (parameter.isNamed) {
      return argumentList.arguments
          .whereType<NamedExpression>()
          .where((argument) => argument.name.label.name == parameter.name)
          .firstOrNull
          ?.expression;
    }

    final positionalArguments = argumentList.arguments.where((argument) => argument is! NamedExpression).toList();
    final parameterIndex = element.formalParameters
        .takeWhile((formalParameter) => formalParameter != parameter)
        .where((formalParameter) => formalParameter.isPositional)
        .length;
    return parameterIndex < positionalArguments.length ? positionalArguments[parameterIndex] : null;
  }
}

class _InvocationCollector extends RecursiveAstVisitor<void> {
  final ExecutableElement target;
  final List<AstNode> invocations = <AstNode>[];

  _InvocationCollector(this.target);

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final element = switch (node.function) {
      SimpleIdentifier(:final element) => element,
      _ => null,
    };
    if (element == target) {
      invocations.add(node);
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.element == target) {
      invocations.add(node);
    }
    super.visitMethodInvocation(node);
  }
}
