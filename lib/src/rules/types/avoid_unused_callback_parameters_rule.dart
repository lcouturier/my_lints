import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidUnusedCallbackParametersRule extends AnalysisRule {
  AvoidUnusedCallbackParametersRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode('avoid_unused_callback_parameters', 'The callback parameter {0} is not used.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addFunctionExpression(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidUnusedCallbackParametersRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Only check if this is a callback (passed as an argument)
    if (!node.isCallback) {
      super.visitFunctionExpression(node);
      return;
    }

    final parameters = node.parameters?.parameters;
    if (parameters == null || parameters.isEmpty) {
      super.visitFunctionExpression(node);
      return;
    }

    // Check each parameter
    for (final param in parameters) {
      if (param is NormalFormalParameter && param.name?.lexeme != null) {
        final paramName = param.name!.lexeme;

        // Skip underscore-prefixed parameters (they're intentionally unused)
        if (paramName.startsWith('_')) {
          continue;
        }

        // Check if the parameter is used in the function body
        final finder = _ParameterUsageFinder(paramName);
        node.body.accept(finder);

        if (!finder.isUsed) {
          rule.reportAtNode(param, arguments: [paramName]);
        }
      }
    }

    super.visitFunctionExpression(node);
  }
}

class _ParameterUsageFinder extends RecursiveAstVisitor<void> {
  _ParameterUsageFinder(this.paramName);

  final String paramName;
  bool isUsed = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == paramName) {
      isUsed = true;
    }
    super.visitSimpleIdentifier(node);
  }
}

extension on FunctionExpression {
  bool get isCallback {
    final parent = this.parent;
    if (parent is ArgumentList) return true;
    return parent is NamedExpression && parent.parent is ArgumentList;
  }
}
