// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that protects emit() calls after await operations in Cubit methods.
///
/// This rule ensures that emit() calls after await operations are protected
/// by an isClosed check to prevent errors when the cubit is closed.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyCubit extends Cubit<MyState> {
///   Future<void> loadData() async {
///     final data = await fetchData();
///     emit(LoadedState(data)); // Error: emit after await without isClosed check
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyCubit extends Cubit<MyState> {
///   Future<void> loadData() async {
///     final data = await fetchData();
///     if (!isClosed) {
///       emit(LoadedState(data));
///     }
///   }
/// }
/// ```
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
    if (node case ClassDeclaration(isCubitClass: true)) {
      for (final m in node.members.whereType<MethodDeclaration>().where((e) => e.body.isAsynchronous)) {
        m.body.accept(_BlockVisitor(rule: rule));
      }
    }
  }
}

class _BlockVisitor extends RecursiveAstVisitor<void> {
  final UnProtectedEmitAfterAwaitRule rule;
  final Set<AstNode> _reportedEmitNodes = {};

  _BlockVisitor({required this.rule});

  @override
  void visitBlock(Block node) {
    _checkBlock(node);
    super.visitBlock(node); // Continue de descendre dans l'AST
  }

  @override
  void visitTryStatement(TryStatement node) {
    super.visitTryStatement(node);

    if (node.body.hasAwait) {
      for (final catchClause in node.catchClauses) {
        _checkCatchClause(catchClause);
      }
    }
  }

  void _checkCatchClause(CatchClause catchClause) {
    final statements = catchClause.body.statements;

    // Si le try contenaient un await, les emit() du catch doivent également être surveillés
    for (final statement in statements) {
      for (final emitNode in _findUnprotectedEmitCalls(statement)) {
        _reportEmit(emitNode);
      }

      if (statement.isClosedEarlyExit) break;
    }
  }

  void _checkBlock(Block block) {
    final statements = block.statements;

    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i];

      if (statement.hasAwait) {
        for (var j = i + 1; j < statements.length; j++) {
          final targetStatement = statements[j];

          for (final emitNode in _findUnprotectedEmitCalls(targetStatement)) {
            _reportEmit(emitNode);
          }

          if (targetStatement.isClosedEarlyExit) break;
        }
      }
    }
  }

  void _reportEmit(MethodInvocation emitNode) {
    if (_reportedEmitNodes.add(emitNode)) {
      rule.reportAtNode(emitNode);
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

List<MethodInvocation> _findUnprotectedEmitCalls(Statement statement) {
  final finder = _UnprotectedEmitFinder();
  statement.accept(finder);
  return finder.emitNodes;
}

class _UnprotectedEmitFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> emitNodes = [];

  @override
  void visitBlock(Block node) {
    for (final statement in node.statements) {
      statement.accept(this);
      if (statement.isClosedEarlyExit) break;
    }
  }

  @override
  void visitIfStatement(IfStatement node) {
    node.expression.accept(this);

    if (node.isNotClosedGuard) {
      node.elseStatement?.accept(this);
      return;
    }

    if (node.isClosedEarlyExit) {
      node.thenStatement.accept(this);
      return;
    }

    super.visitIfStatement(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {}

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

  bool get isNotClosedGuard {
    return switch (this) {
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

  bool get isClosedEarlyExit {
    if (this case IfStatement(expression: SimpleIdentifier(name: 'isClosed'), thenStatement: final thenStatement)) {
      if (thenStatement is ReturnStatement) return true;
      return thenStatement is Block &&
          thenStatement.statements.isNotEmpty &&
          thenStatement.statements.last is ReturnStatement;
    }
    return false;
  }
}
