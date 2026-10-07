import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports when an iterable is converted to a list before calling `join()`.
///
/// This is unnecessary because `join()` can be called directly on an iterable without converting it to a list first.
/// example:
/// ```dart
/// String combine(Iterable<String> values) => values.toList().join(',');
/// ```
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
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(element: MethodElement(name: 'join', library: LibraryElement(isDartCore: true))),
      target: MethodInvocation(
        methodName: SimpleIdentifier(element: MethodElement(name: 'toList', library: LibraryElement(isDartCore: true))),
      ),
    )) {
      rule.reportAtNode(node);
    }
  }
}
