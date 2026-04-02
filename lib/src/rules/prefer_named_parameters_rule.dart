import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects when a parameter's field or setter is reassigned.
class PReferNamedParametersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    '',
    '',
    correctionMessage: 'Use the optional orElse parameter to provide a default if no element matches.',
    severity: DiagnosticSeverity.WARNING,
  );

  PReferNamedParametersRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addMethodDeclaration(this, visitor)
      ..addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PReferNamedParametersRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node case MethodDeclaration(parameters: final params?) when params.parameters.length > 1) {
      if (params.parameters.every((e) => e.isNamed)) return;
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    //if (node case FunctionDeclaration(parameters: final params?) when params.parameters.length > 1) {}
  }
}
