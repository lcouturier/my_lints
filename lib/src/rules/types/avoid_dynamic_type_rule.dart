import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that avoids declarations using the `dynamic` type.
///
/// Prefer a concrete type when known, or `Object?` when a value may have any
/// type but should still be type-checked before use.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// dynamic result;
/// ```
///
/// ✅ Good:
/// ```dart
/// Object? result;
/// ```
class AvoidDynamicTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_dynamic_type',
    'Using dynamic is considered unsafe since it can easily result in runtime errors.',
    correctionMessage: 'Try replacing it with a different type.',
  );

  AvoidDynamicTypeRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addNamedType(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidDynamicTypeRule rule;

  @override
  void visitNamedType(NamedType node) {
    if (node.type is DynamicType) {
      rule.reportAtNode(node);
    }
  }
}
