import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidUselessAsyncMethodRule extends AnalysisRule {
  AvoidUselessAsyncMethodRule()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_useless_async_method',
    'Avoid useless async method.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addMethodDeclaration(this, _Visitor(this))
      ..addFunctionDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidUselessAsyncMethodRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme.startsWith('_')) return;
    if (!node.body.isAsynchronous) return;

    final visitor = _AwaitFinderVisitor();
    node.body.accept(visitor);
    if (visitor.hasAwait) return;

    rule.reportAtNode(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.name.lexeme.startsWith('_')) return;

    final body = node.functionExpression.body;
    if (!body.isAsynchronous) return;

    final visitor = _AwaitFinderVisitor();
    body.accept(visitor);
    if (visitor.hasAwait) return;

    rule.reportAtNode(node);
  }
}

class _AwaitFinderVisitor extends RecursiveAstVisitor<void> {
  bool hasAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    hasAwait = true;
    super.visitAwaitExpression(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    node.expression.visitChildren(this);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    node.visitChildren(this);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (!node.functionExpression.body.isAsynchronous) return;

    node.functionExpression.body.accept(this);
  }
}
