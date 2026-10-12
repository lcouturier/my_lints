import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports `==` or `!=` between identical simple identifiers.
///
/// Such a comparison is always true for `==` and always false for `!=`.
/// Remove the redundant comparison or use the intended boolean result directly.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// bool same(bool value) => value == value;
/// ```
///
/// ✅ Good:
/// ```dart
/// bool same(bool value) => true;
/// ```
class AvoidCompareSameValueRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_compare_same_value',
    'Avoid comparing the same value.',
    correctionMessage: 'Remove the comparison.',
    severity: DiagnosticSeverity.ERROR,
  );

  AvoidCompareSameValueRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidCompareSameValueRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      leftOperand: SimpleIdentifier(name: final left),
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: SimpleIdentifier(name: final right),
    )) {
      if (left == right) rule.reportAtNode(node);
    }
  }
}
