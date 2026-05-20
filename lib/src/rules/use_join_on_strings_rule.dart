import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects when a parameter's field or setter is reassigned.
class UseJoinOnStringsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_join_on_non_strings',
    'Avoid calling join() on Iterable that does not contain Strings.',
    correctionMessage: 'Convert elements to String before calling join(), e.g. map((e) => e.toString()).join().',
  );

  UseJoinOnStringsRule() : super(name: code.name, description: code.problemMessage);

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

  final UseJoinOnStringsRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;
    if (!(element is MethodElement && element.name == 'join' && element.library.isDartCore)) return;

    final target = node.target;
    if (target == null) return;

    final type = target.staticType;
    if (type is! InterfaceType) return;

    if (!_isIterable(type)) return;
    if (type.typeArguments.isEmpty) return;
    if (type.typeArguments.first.isDartCoreString) return;

    rule.reportAtNode(node);
  }

  bool _isIterable(InterfaceType type) {
    return type.isDartCoreIterable || type.allSupertypes.any((t) => t.isDartCoreIterable);
  }
}
