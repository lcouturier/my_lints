import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports async methods or functions that do not contain any `await` expressions, making the `async` modifier unnecessary.
///
/// Example:
/// ```dart
/// // Bad
/// Future<void> foo() async {
///   print('Hello');
/// }
///
/// // Good
/// Future<void> foo() {
///   print('Hello');
/// }
/// ```
class AvoidUselessAsyncMethodRule extends AnalysisRule {
  AvoidUselessAsyncMethodRule() : super(name: code.name, description: code.problemMessage);

  static const code = LintCode('avoid_useless_async_method', 'Avoid useless async method.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addMethodDeclaration(this, visitor)
      ..addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidUselessAsyncMethodRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node case MethodDeclaration(
      name: Token(lexeme: final name),
      body: FunctionBody(isAsynchronous: true),
      isStatic: false,
      isGetter: false,
      isSetter: false,
    ) when !name.startsWith('_')) {
      final visitor = _AwaitFinderVisitor();
      node.body.accept(visitor);
      if (visitor.hasAwait) return;

      rule.reportAtNode(node);
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node case FunctionDeclaration(
      name: Token(lexeme: final name),
      functionExpression: FunctionExpression(body: final FunctionBody body),
      isGetter: false,
      isSetter: false,
    ) when !name.startsWith('_') && body.isAsynchronous) {
      final visitor = _AwaitFinderVisitor();
      body.accept(visitor);
      if (visitor.hasAwait) return;

      rule.reportAtNode(node);
    }
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
}
