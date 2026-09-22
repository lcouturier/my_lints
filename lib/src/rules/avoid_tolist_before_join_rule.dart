import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidToListBeforeJoinRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_tolist_before_join',
    'Avoid calling toList() before join() on Iterable.',
    correctionMessage: 'Call join() directly on the Iterable without converting it to a List first.',
  );

  AvoidToListBeforeJoinRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidToListBeforeJoinRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;
    if (!(element is MethodElement && element.name == 'join' && element.library.isDartCore)) return;

    final target = node.target;
    if (target == null) return;

    if (target is! MethodInvocation) return;
    final toListInvocation = target;

    final toListElement = toListInvocation.methodName.element;
    if (!(toListElement is MethodElement && toListElement.name == 'toList' && toListElement.library.isDartCore)) return;

    rule.reportAtNode(node);
  }
}
