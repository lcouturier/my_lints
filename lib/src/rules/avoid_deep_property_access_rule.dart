import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidDeepPropertyAccessRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_deep_property_access',
    'Avoid deep property access (e.g. a.b.c.d). Consider breaking it into multiple lines or using intermediate variables.',
  );

  AvoidDeepPropertyAccessRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addPropertyAccess(this, _Visitor(this));
  }
}

class _Visitor extends RecursiveAstVisitor<int> {
  final AvoidDeepPropertyAccessRule rule;

  _Visitor(this.rule);

  int compute(Expression expression) {
    return expression.accept(this) ?? 1;
  }

  @override
  int visitPropertyAccess(PropertyAccess node) {
    final int depth = 1 + (node.target?.accept(this) ?? 1);
    if (depth > 3) {
      rule.reportAtNode(node);
    }
    return depth;
  }
}
