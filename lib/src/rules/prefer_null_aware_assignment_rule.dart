// ignore_for_file: unused_local_variable

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prefers using null-aware assignment (??=) instead of explicit null checks and assignments.
/// This rule checks for patterns where a variable is explicitly checked for null and then assigned a value, and suggests using the null-aware assignment operator (??=) instead.
/// Example:
/// ```dart
/// if (a == null) {
///   a = 42;
/// }
/// ```
/// can be replaced with:
/// ```dart
/// a ??= 42;
/// ```
class PreferNullAwareAssignmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_null_aware_assignment',
    "Prefer using null-aware assignment.",
    correctionMessage: "Use ??= instead of explicit null check and assignment.",
  );

  PreferNullAwareAssignmentRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferNullAwareAssignmentRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    if (node.expression case BinaryExpression(
      leftOperand: SimpleIdentifier(:final name),
      operator: Token(type: TokenType.EQ_EQ),
      rightOperand: NullLiteral(),
    )) {
      final thenStatement = node.thenStatement;
      if (thenStatement case Block(:final statements) when statements.length == 1) {
        final actualStatement = statements.single;
        if (actualStatement case ExpressionStatement(
          expression: AssignmentExpression(
            leftHandSide: SimpleIdentifier(name: final exprName),
            operator: Token(type: TokenType.EQ),
          ),
        ) when name == exprName) {
          rule.reportAtNode(node);
        }
      }
    }

    super.visitIfStatement(node);
  }
}
