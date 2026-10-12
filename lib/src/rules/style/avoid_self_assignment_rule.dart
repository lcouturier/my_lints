import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects assigning a variable to itself.
///
/// A self-assignment does not change the variable's value and can usually be
/// removed without affecting the surrounding code.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// count = count;
/// ```
///
/// ✅ Good:
/// ```dart
/// // Remove the redundant assignment.
/// ```
class AvoidSelfAssignmentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_self_assignment',
    'Avoid self-assignment.',
    correctionMessage: 'Remove the self-assignment.',
  );

  AvoidSelfAssignmentRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addAssignmentExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidSelfAssignmentRule rule;

  _Visitor(this.rule);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node case AssignmentExpression(
      operator: Token(type: TokenType.EQ),
      leftHandSide: SimpleIdentifier(name: final left),
      rightHandSide: SimpleIdentifier(name: final right),
    )) {
      if (left == right) rule.reportAtNode(node);
    }
  }
}
