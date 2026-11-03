import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that avoids combining a scoped `let` call with a fallback value.
///
/// This rule flags `let` calls used directly as the left operand of `??`.
/// A null-aware expression is clearer when the result only needs a fallback.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// name.let((value) => value.toUpperCase()) ?? '';
/// ```
///
/// ✅ Good:
/// ```dart
/// name?.toUpperCase() ?? '';
/// ```
class AvoidLetScopedFunctionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_let_scoped_function',
    'Avoid using let before the if-null operator.',
    correctionMessage: 'Use a null-aware expression before the fallback value.',
  );

  AvoidLetScopedFunctionRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidLetScopedFunctionRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(:final leftOperand, operator: Token(type: TokenType.QUESTION_QUESTION))) {
      final left = leftOperand.unParenthesized;
      if (left case MethodInvocation(methodName: SimpleIdentifier(name: 'let'))) {
        rule.reportAtNode(left);
      }
    }
  }
}
