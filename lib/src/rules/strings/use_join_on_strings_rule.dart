import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule whose current implementation reports core `join()` calls on
/// `Iterable<String>` targets.
///
/// This differs from the diagnostic's stated intent, which is to report
/// non-string elements. The predicate should be corrected before documenting a
/// recommended replacement.
///
/// ## Current behavior
///
/// ⚠️ Reported by the current implementation:
/// ```dart
/// Iterable<String> values = ['a', 'b'];
/// values.join();
/// ```
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
    if (node case MethodInvocation(
      target: Expression(staticType: InterfaceType(isIterable: true, :final typeArguments)),
      methodName: SimpleIdentifier(name: 'join', element: MethodElement(library: LibraryElement(name: 'dart.core'))),
    ) when typeArguments.isNotEmpty && typeArguments.first.isDartCoreString) {
      rule.reportAtNode(node);
    }
  }
}

extension on InterfaceType {
  bool get isIterable => isDartCoreIterable || allSupertypes.any((t) => t.isDartCoreIterable);
}
