import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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
    if (a.runtimeType != b.runtimeType) {
      return false;
    }

    final aChildren = a.childEntities.whereType<AstNode>().toList();
    final bChildren = b.childEntities.whereType<AstNode>().toList();

    if (aChildren.length != bChildren.length) {
      return false;
    }

    for (var i = 0; i < aChildren.length; i++) {
      if (!_sameAst(aChildren[i], bChildren[i])) {
        return false;
      }
    }

    return true;
  }
}
