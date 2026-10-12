import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that identifies unused parameters in inline callbacks.
///
/// Rename an intentionally unused parameter with an underscore prefix so its
/// purpose is clear and it is not mistaken for an accidental omission.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// values.map((value) => 0);
/// ```
///
/// ✅ Good:
/// ```dart
/// values.map((_) => 0);
/// ```
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
    if (node case FunctionExpression(
      isCallback: true,
      parameters: FormalParameterList(parameters: final params),
    ) when params.isNotEmpty) {
      for (final param
          in params
              .whereType<NormalFormalParameter>()
              .where((e) => e.name?.lexeme != null)
              .where((e) => !e.name!.lexeme.startsWith('_'))) {
        final paramName = param.name!.lexeme;

        var isUsed = false;
        final finder = _ParameterUsageFinder(paramName, (_) => isUsed = true);
        node.body.accept(finder);
        if (!isUsed) {
          rule.reportAtNode(param, arguments: [paramName]);
        }
      }
    }

    super.visitFunctionExpression(node);
  }
}

class _ParameterUsageFinder extends RecursiveAstVisitor<void> {
  _ParameterUsageFinder(this.paramName, this.onFound);

  final String paramName;
  final void Function(SimpleIdentifier node) onFound;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == paramName) {
      onFound(node);
    }
    super.visitSimpleIdentifier(node);
  }
}

extension on FunctionExpression {
  bool get isCallback {
    return switch (parent) {
      ArgumentList() => true,
      NamedExpression() => parent?.parent is ArgumentList,
      _ => false,
    };
  }
}
