import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferReturnAwaitRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_return_await',
    'Prefer returning the awaited result of a Future.',
    correctionMessage:
        'Consider using "return await" instead of returning the Future directly when inside a try-catch block.',
  );

  PreferReturnAwaitRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferReturnAwaitRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final body = node.functionExpression.body;
    if (!body.isAsynchronous) return;

    final returnType = node.returnType?.type;
    if (returnType != null && returnType.isDartAsyncFuture) {
      final visitor = _TryStatementVisitor(rule);
      body.accept(visitor);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final body = node.body;
    if (!body.isAsynchronous) return;

    final returnType = node.returnType?.type;
    if (returnType != null && returnType.isDartAsyncFuture) {
      final visitor = _TryStatementVisitor(rule);
      body.accept(visitor);
    }
  }
}

class _TryStatementVisitor extends RecursiveAstVisitor<void> {
  final PreferReturnAwaitRule rule;

  _TryStatementVisitor(this.rule);

  @override
  void visitTryStatement(TryStatement node) {
    if (node.catchClauses.isEmpty) return;

    final visitor = _ReturnFinderVisitor();
    node.body.visitChildren(visitor); // Lire que le premier niveau de return dans le try

    for (final returnNode
        in visitor.returnNodes.where((e) => e.expression != null).where((e) => e.expression is! AwaitExpression)) {
      final expr = returnNode.expression;
      final type = expr?.staticType;
      if (type.isFutureLike) {
        rule.reportAtNode(expr);
      }
    }

    super.visitTryStatement(node);
  }
}

class _ReturnFinderVisitor extends RecursiveAstVisitor<void> {
  final List<ReturnStatement> returnNodes = [];

  @override
  void visitReturnStatement(ReturnStatement node) {
    returnNodes.add(node);
    super.visitReturnStatement(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // 🚫 Ne pas descendre dans les fonctions locales
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // 🚫 idem si jamais rencontré imbriqué
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // 🚫 sécurité supplémentaire si tu traverses trop large
  }
}
