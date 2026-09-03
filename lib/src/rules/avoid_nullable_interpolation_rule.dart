import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidNullableInterpolationRule extends AnalysisRule {
  AvoidNullableInterpolationRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'avoid_nullable_interpolation',
    'Avoid using nullable values in string interpolation.',
    correctionMessage: 'Consider using a non-nullable value or providing a default value.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidNullableInterpolationRule rule;

  _Visitor(this.rule);

  @override
  void visitStringInterpolation(StringInterpolation node) {
    for (final element in node.elements) {
      if (element case InterpolationExpression(
        expression: SimpleIdentifier(staticType: final type),
      ) when (type.isNullable)) {
        rule.reportAtNode(element);
      }
    }
    super.visitStringInterpolation(node);
  }
}
