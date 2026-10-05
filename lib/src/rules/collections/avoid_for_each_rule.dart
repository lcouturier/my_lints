import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidForEachRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_for_each',
    'Avoid using forEach',
    correctionMessage: 'Consider using a for-in loop instead of forEach.',
  );

  AvoidForEachRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);

    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidForEachRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'forEach'),
      target: Expression(staticType: final targetType?),
    ) when listChecker.isAssignableFromType(targetType)) {
      rule.reportAtOffset(node.methodName.offset, node.methodName.length);
    }
  }
}
