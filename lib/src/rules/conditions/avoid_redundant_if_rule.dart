// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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
    final redundant = _redundantBooleanReturn(node);
    if (redundant != null) {
      rule.reportAtNode(redundant);
    }
  }

  /// Détecte si [node] est un `if` sans `else` qui retourne un booléen
  /// suivi immédiatement du retour opposé. Retourne le nœud si redondant.
  IfStatement? _redundantBooleanReturn(IfStatement node) {
    if (node.elseStatement != null) return null;

    final thenReturn = _extractReturn(node.thenStatement);
    final thenExpr = thenReturn?.expression?.unParenthesized;
    if (thenExpr is! BooleanLiteral) return null;

    final block = node.parent;
    if (block is! Block) return null;

    final statements = block.statements;
    final nextIndex = statements.indexOf(node) + 1;
    if (nextIndex >= statements.length) return null;

    final nextReturn = _extractReturn(statements[nextIndex]);
    final nextExpr = nextReturn?.expression?.unParenthesized;
    if (nextExpr is! BooleanLiteral) return null;

    final isRedundant =
        (thenExpr.value == true && nextExpr.value == false) || (thenExpr.value == false && nextExpr.value == true);

    return isRedundant ? node : null;
  }

  ReturnStatement? _extractReturn(Statement? statement) {
    return switch (statement) {
      ReturnStatement() => statement,
      Block(statements: [final ReturnStatement returnStmt]) => returnStmt,
      _ => null,
    };
  }
}
