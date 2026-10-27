import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that prefers `first` over accessing an iterable's first item by index.
///
/// The `first` getter communicates intent directly and avoids spelling out the
/// zero index when retrieving the first element.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// final firstName = names[0];
/// ```
///
/// ✅ Good:
/// ```dart
/// final firstName = names.first;
/// ```
class PreferFirstRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_first_over_index',
    "Use '.first' instead of accessing the first element by index.",
    correctionMessage: "Replace with '.first'.",
  );

  PreferFirstRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addIndexExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferFirstRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      target: Expression(staticType: DartType(isListOrSet: true)),
      methodName: SimpleIdentifier(name: 'elementAt'),
      argumentList: ArgumentList(arguments: [IntegerLiteral(value: 0)]),
    )) {
      rule.reportAtNode(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.isFirstElementAccess) {
      rule.reportAtNode(node);
    }
    super.visitIndexExpression(node);
  }
}

extension on IndexExpression {
  /// Returns `true` when this index access targets the first element of a
  /// list or set, i.e. the index is the integer literal `0` and the target
  /// has a static type of `List` or `Set`.
  bool get isFirstElementAccess {
    return switch (this) {
      IndexExpression(target: Expression(staticType: DartType(isListOrSet: true)), index: IntegerLiteral(value: 0)) =>
        true,
      _ => false,
    };
  }
}
