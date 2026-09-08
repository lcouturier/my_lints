// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class ProperSuperCallsRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'proper_super_calls',
    "Ensure that 'super.initState()' and 'super.dispose()' are called in the correct order.",
  );

  ProperSuperCallsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final ProperSuperCallsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'initState') {
        final visitor = _InitStateVisitor(method: member);
        member.body.visitChildren(visitor);
        final (:hasSuperCalled, :statement) = visitor.hasSuperCalled;
        if (!hasSuperCalled) {
          rule.reportAtNode(statement);
        }
      }
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        final visitor = _DisposeVisitor(method: member);
        member.body.visitChildren(visitor);
        final (:hasSuperCalled, :statement) = visitor.hasSuperCalled;
        if (!hasSuperCalled) {
          rule.reportAtNode(statement);
        }
      }
    }
  }
}

typedef _VisitorResult = ({bool hasSuperCalled, Expression? statement});

class _InitStateVisitor extends SimpleAstVisitor<void> {
  _InitStateVisitor({required this.method});

  final MethodDeclaration method;
  late _VisitorResult hasSuperCalled = (hasSuperCalled: false, statement: null);

  @override
  void visitBlock(Block node) {
    if (node.statements.isEmpty) return;
    if (node.statements.first is! ExpressionStatement) return;

    for (var i = 0; i < node.statements.length; i++) {
      if (node.statements[i] is ExpressionStatement) {
        final expression = (node.statements[i] as ExpressionStatement).expression;
        if (expression is MethodInvocation &&
            expression.methodName.name == 'initState' &&
            expression.target is SuperExpression) {
          hasSuperCalled = (hasSuperCalled: i == 0, statement: expression);
        }
      }
    }

    super.visitBlock(node);
  }
}

class _DisposeVisitor extends SimpleAstVisitor<void> {
  _DisposeVisitor({required this.method});

  final MethodDeclaration method;
  late _VisitorResult hasSuperCalled = (hasSuperCalled: false, statement: null);

  @override
  void visitBlock(Block node) {
    if (node.statements.isEmpty) return;
    if (node.statements.last is! ExpressionStatement) return;

    for (var i = 0; i < node.statements.length; i++) {
      if (node.statements[i] is ExpressionStatement) {
        final expression = (node.statements[i] as ExpressionStatement).expression;
        if (expression is MethodInvocation &&
            expression.methodName.name == 'dispose' &&
            expression.target is SuperExpression) {
          hasSuperCalled = (hasSuperCalled: (i == (node.statements.length - 1)), statement: expression);
        }
      }
    }

    super.visitBlock(node);
  }
}
