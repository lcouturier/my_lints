// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class UnProtectedEmitAfterAwaitRule extends AnalysisRule {
  static const code = LintCode(
    'unprotected_emit_after_await',
    'L\'appel à emit() après une opération asynchrone doit être protégé par un contrôle sur isClosed.',
    correctionMessage: 'Ajoutez "if (!isClosed)" ou "if (isClosed) return;" avant d\'émettre le nouvel état.',
    severity: DiagnosticSeverity.WARNING,
  );

  UnProtectedEmitAfterAwaitRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final UnProtectedEmitAfterAwaitRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element == null) return;
    if (!cubitChecker.isSuperOf(element)) return;

    for (final m in node.members.whereType<MethodDeclaration>().where((e) => e.body.isAsynchronous)) {
      m.body.accept(_BlockVisitor(rule: rule));
    }
  }
}

class _BlockVisitor extends RecursiveAstVisitor<void> {
  final UnProtectedEmitAfterAwaitRule rule;

  _BlockVisitor({required this.rule});

  @override
  void visitBlock(Block node) {
    _checkBlock(node);
    super.visitBlock(node); // Continue de descendre dans l'AST
  }

  @override
  void visitTryStatement(TryStatement node) {
    super.visitTryStatement(node);

    // 1. Analyser le corps du try
    _checkBlock(node.body);

    // 2. Analyser les blocs catch s'ils existent
    for (final catchClause in node.catchClauses) {
      _checkCatchClause(catchClause);
    }

    // 3. Analyser le bloc finally s'il existe
    if (node.finallyBlock != null) {
      _checkBlock(node.finallyBlock!);
    }
  }

  void _checkCatchClause(CatchClause catchClause) {
    final statements = catchClause.body.statements;

    // Si le try contenaient un await, les emit() du catch doivent également être surveillés
    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i];

      // Si un emit() est présent dans le catch sans garde préalable dans ce même catch
      final emitCalls = _findEmitCalls(statement);
      if (emitCalls.isNotEmpty) {
        final hasGuardBefore = statements.take(i).any((s) => s.isIsClosedGuard);

        if (!hasGuardBefore) {
          for (final emitNode in emitCalls) {
            rule.reportAtNode(emitNode);
          }
        }
      }
    }
  }

  void _checkBlock(Block block) {
    final statements = block.statements;

    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i];

      if (statement.hasAwait) {
        // 1. Chercher le garde immédiatement après le await
        final nextStatement = (i + 1 < statements.length) ? statements[i + 1] : null;

        if (nextStatement == null || !nextStatement.isIsClosedGuard) {
          // 2. Si l'instruction suivante N'EST PAS un garde 'if (!isClosed)',
          // on inspecte le reste du bloc à la recherche d'emit() non protégés.
          for (var j = i + 1; j < statements.length; j++) {
            final targetStatement = statements[j];

            // Si on croise un garde plus loin, les emit() suivants sont protégés
            if (targetStatement.isIsClosedGuard) break;

            final emitCalls = _findEmitCalls(targetStatement);
            for (final emitNode in emitCalls) {
              rule.reportAtNode(emitNode);
            }
          }
        }
      }
    }
  }
}

class _AwaitFinder extends RecursiveAstVisitor<void> {
  bool foundAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    foundAwait = true;
  }

  // On stoppe la recherche si le await est isolé dans une closure enfant
  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Ne rien faire : évite de descendre dans un sous-corps async
  }
}

List<MethodInvocation> _findEmitCalls(Statement statement) {
  final finder = _EmitFinder();
  statement.visitChildren(finder);
  return finder.emitNodes;
}

class _EmitFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> emitNodes = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'emit') {
      emitNodes.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

extension on Statement {
  /// Returns true if the statement contains an await expression
  ///
  /// Examples:
  /// - `await Future.delayed(Duration(seconds: 1));`
  /// - `final result = await someAsyncFunction();`
  bool get hasAwait {
    final visitor = _AwaitFinder();
    visitChildren(visitor);
    return visitor.foundAwait;
  }

  /// Returns true if the statement is an if statement that checks if the cubit is closed
  ///
  /// Examples:
  /// - `if (!isClosed) return;`
  /// - `if (isClosed) return;`
  bool get isIsClosedGuard {
    return switch (this) {
      IfStatement(expression: SimpleIdentifier(name: 'isClosed')) => true,
      IfStatement(
        expression: PrefixExpression(
          operator: Token(type: TokenType.BANG),
          operand: SimpleIdentifier(name: 'isClosed'),
        ),
      ) =>
        true,
      _ => false,
    };
  }
}
