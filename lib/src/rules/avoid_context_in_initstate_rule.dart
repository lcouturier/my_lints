// Bad
// @override
// void initState() {
//   super.initState();
//   Navigator.of(context).push(...);
// }

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidContextInInitStateRule extends AnalysisRule {
  static LintCode code = const LintCode('avoid_context_in_initState', "Don't use 'context' in 'initState'.");

  AvoidContextInInitStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidContextInInitStateRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'initState') {
        final visitor = _ContextInInitStateVisitor();
        member.body.visitChildren(visitor);
        final (found, node) = visitor.foundContext;
        if (found) {
          rule.reportAtNode(node);
        }
      }
    }
  }
}

class _ContextInInitStateVisitor extends RecursiveAstVisitor<void> {
  _ContextInInitStateVisitor();
  bool insideSafeAsync = false;

  static const _safeAsyncMethods = {'addPostFrameCallback', 'scheduleFrameCallback'};

  (bool, AstNode?) foundContext = (false, null);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;

    if (_safeAsyncMethods.contains(name)) {
      return;
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final type = node.staticType;

    if (type == null) return;

    if (type.getDisplayString() == 'BuildContext') {
      foundContext = (true, node);
    }
  }
}
