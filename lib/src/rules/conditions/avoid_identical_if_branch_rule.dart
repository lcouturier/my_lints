import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects if statements with identical then and else branches.
///
/// Having identical branches in an if-else statement is redundant and confusing.
/// Remove the conditional or ensure the branches are different.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// if (condition) {
///   print('Hello');
/// } else {
///   print('Hello');
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// print('Hello');
/// // or
/// if (condition) {
///   print('Hello');
/// } else {
///   print('Goodbye');
/// }
/// ```
class AvoidIdenticalIfBranchRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_identical_if_branch',
    'Avoid identical if branches.',
    correctionMessage: 'Consider refactoring the code to eliminate redundant branches.',
  );

  AvoidIdenticalIfBranchRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _IfVisitor(this));
  }
}

class _IfVisitor extends SimpleAstVisitor<void> {
  final AvoidIdenticalIfBranchRule rule;

  _IfVisitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final thenBranch = node.thenStatement;
    final elseBranch = node.elseStatement;

    if (elseBranch == null) return;

    if (_sameAst(thenBranch, elseBranch)) {
      rule.reportAtNode(node);
    }
  }

  bool _sameAst(AstNode a, AstNode b) {
    return a.toSource() == b.toSource();
  }
}
