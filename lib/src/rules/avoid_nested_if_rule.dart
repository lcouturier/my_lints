import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects nested if statements.
/// Nested if statements can lead to confusion and make code harder to read. This rule checks for if statements that are nested more than 3 levels deep and reports them as a warning.
/// For example, the following code will trigger a warning:
/// ```dart
/// void f(int a) {
///   if (a > 0) {
///     if (a < 10) {
///       if (a % 2 == 0) {
///         print('a is a positive even number less than 10');
///       }
///     }
///   }
/// }
class AvoidNestedIfRule extends AnalysisRule {
  static const LintCode code = LintCode('avoid_nested_if', 'Avoid nested if statements.');

  AvoidNestedIfRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _Visitor(this));
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidNestedIfRule rule;
  int _depth = 0;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    _depth++;

    if (_depth > 2) {
      rule.reportAtNode(node);
    }

    super.visitIfStatement(node);

    _depth--;
  }
}
