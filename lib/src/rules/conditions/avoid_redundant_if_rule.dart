// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that detects if statements that simply return a boolean.
///
/// When an `if` statement returns `true` in its body and `false` immediately
/// after, the whole construct can be replaced by `return condition;`.
/// The symmetric pattern (return `false` in the body, `true` after) is also
/// detected and can be replaced by `return !condition;`.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// bool isReady(bool ready) {
///   if (ready) {
///     return true;
///   }
///   return false;
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// bool isReady(bool ready) => ready;
/// ```
class AvoidRedundantIfRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_if',
    'Avoid redundant if-else that returns a boolean.',
    correctionMessage: 'Consider replacing the if-else with a direct return.',
  );

  AvoidRedundantIfRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidRedundantIfRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final elseStatement = node.elseStatement;
    if (elseStatement != null) return;

    final thenStatement = node.thenStatement;
    final thenReturn = _extractReturn(thenStatement);
    if (thenReturn == null) return;

    final thenExpr = thenReturn.expression?.unParenthesized;
    if (thenExpr is! BooleanLiteral) return;

    final body = node.parent;
    if (body is! Block) return;

    final statements = body.statements;
    final nextIndex = statements.indexWhere((s) => s == node) + 1;
    if (nextIndex >= statements.length) return;
    final nextStatement = statements[nextIndex];
    final nextReturn = _extractReturn(nextStatement);
    if (nextReturn == null) return;

    final nextExpr = nextReturn.expression?.unParenthesized;
    if (nextExpr is! BooleanLiteral) return;

    if (thenExpr.value == true && nextExpr.value == false) {
      rule.reportAtNode(node);
    } else if (thenExpr.value == false && nextExpr.value == true) {
      rule.reportAtNode(node);
    }
  }

  ReturnStatement? _extractReturn(Statement? statement) {
    return switch (statement) {
      ReturnStatement() => statement,
      Block(statements: [final ReturnStatement returnStmt]) => returnStmt,
      _ => null,
    };
  }
}
