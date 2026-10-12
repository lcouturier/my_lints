// ignore_for_file: unused_local_variable

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports a null check followed by assignment to the same variable.
///
/// It recognizes `if (variable == null)` with no `else` and a single assignment
/// to that variable in the `if` body. Use `??=` to express this pattern directly.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// if (value == null) {
///   value = 42;
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// value ??= 42;
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
    if (node.isReplacable) {
      rule.reportAtNode(node);
    }

    super.visitIfStatement(node);
  }
}

extension IfStatmentExtensions on IfStatement {
  bool get isReplacable {
    if (expression case BinaryExpression(
      leftOperand: SimpleIdentifier(:final name),
      operator: Token(type: TokenType.EQ_EQ),
      rightOperand: NullLiteral(),
    )) {
      if (elseStatement != null) return false;

      if (thenStatement case Block(:final statements) when statements.length == 1) {
        final actualStatement = statements.single;
        if (actualStatement case ExpressionStatement(
          expression: AssignmentExpression(
            leftHandSide: SimpleIdentifier(name: final exprName),
            operator: Token(type: TokenType.EQ),
          ),
        ) when name == exprName) {
          return true;
        }
      }
    }
    return false;
  }
}
