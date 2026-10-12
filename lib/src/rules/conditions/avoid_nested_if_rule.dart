import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports `if` statements nested more than two levels deep.
///
/// Use guard clauses to handle exceptional cases and keep the main path
/// unindented.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// void f(int a) {
///   if (a > 0) {
///     if (a < 10) {
///       if (a % 2 == 0) {
///         print(a);
///       }
///     }
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// void f(int a) {
///   if (a <= 0) return;
///   if (a >= 10) return;
///   if (a % 2 != 0) return;
///   print(a);
/// }
/// ```
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
