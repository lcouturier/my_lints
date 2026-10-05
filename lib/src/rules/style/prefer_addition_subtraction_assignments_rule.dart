import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prefers using `+=` and `-=` instead of `++` and `--`.
///
/// This rule checks for the use of postfix increment (`++`) and decrement (`--`) operators in Dart code. It reports a diagnostic if these operators are used outside of `for` loop declarations or expressions, suggesting that developers should use compound assignment operators (`+=` and `-=`) instead for better readability and maintainability.
/// example
/// ```dart
/// void main() {
///   int x = 5;
///   x++; // This will be reported by the rule.
///   x--; // This will also be reported by the rule.
/// }
/// ```
class PreferAdditionSubtractionAssignmentsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_addition_subtraction_assignments',
    'Prefer using += and -= instead of ++ and --',
  );

  PreferAdditionSubtractionAssignmentsRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addPostfixExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferAdditionSubtractionAssignmentsRule rule;

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node case PostfixExpression(
      parent: final parent?,
      operator: Token(type: TokenType.PLUS_PLUS) || Token(type: TokenType.MINUS_MINUS),
    ) when parent is! ForPartsWithDeclarations && parent is! ForPartsWithExpression) {
      rule.reportAtNode(node);
    }
  }
}
