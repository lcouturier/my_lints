import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports direct `setState` calls in asynchronous Flutter `State`
/// methods after an asynchronous gap without a mounted check.
///
/// The check must occur after the latest `await` and either guard the call or
/// return early when the `State` is no longer mounted.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// Future<void> load() async {
///   final value = await loadValue();
///   setState(() => _value = value);
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// Future<void> load() async {
///   final value = await loadValue();
///   if (!mounted) return;
///   setState(() => _value = value);
/// }
/// ```
class AvoidSetStateAfterAwaitWithoutMountedCheckRule extends AnalysisRule {
  static const code = LintCode(
    'avoid_set_state_after_await_without_mounted_check',
    'Avoid calling setState after an await without checking mounted.',
    correctionMessage: 'Check mounted after the asynchronous operation before calling setState.',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidSetStateAfterAwaitWithoutMountedCheckRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidSetStateAfterAwaitWithoutMountedCheckRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isFlutterStatefulWidget: true, :final asyncMethods)) {
      for (final method in asyncMethods) {
        final visitor = _AsyncMethodVisitor();
        method.body.accept(visitor);

        for (final invocation in visitor.setStateInvocations) {
          final lastAwaitOffset = visitor.awaitOffsets.where((offset) => offset < invocation.offset).lastOrNull;
          if (lastAwaitOffset != null && !_isMountedProtected(invocation, method.body, lastAwaitOffset)) {
            rule.reportAtNode(invocation);
          }
        }
      }
    }
  }
}

class _AsyncMethodVisitor extends RecursiveAstVisitor<void> {
  final List<int> awaitOffsets = [];
  final List<MethodInvocation> setStateInvocations = [];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitOffsets.add(node.offset);
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'setState'),
      :final realTarget,
    ) when (realTarget == null || realTarget is ThisExpression)) {
      setStateInvocations.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

bool _isMountedProtected(MethodInvocation invocation, FunctionBody body, int lastAwaitOffset) {
  AstNode? current = invocation;

  while (current != null && current != body) {
    final parent = current.parent;

    if (parent is IfStatement && parent.offset > lastAwaitOffset) {
      final condition = parent.expression.unParenthesized;
      if ((condition.isMounted) && _contains(parent.thenStatement, invocation)) return true;
      final elseStatement = parent.elseStatement;
      if (condition.isNotMounted && elseStatement != null) {
        if (_contains(elseStatement, invocation)) return true;
      }
    }

    if (parent is Block && current is Statement) {
      final statementIndex = parent.statements.indexOf(current);
      if (statementIndex >= 0) {
        for (final statement in parent.statements.take(statementIndex).toList().reversed) {
          if (statement.offset <= lastAwaitOffset) break;
          if (_isMountedEarlyExit(statement)) return true;
        }
      }
    }

    current = parent;
  }

  return false;
}

bool _isMountedEarlyExit(Statement statement) {
  if (statement case IfStatement(:final expression, :final thenStatement, elseStatement: null)) {
    return expression.unParenthesized.isNotMounted && _alwaysReturns(thenStatement);
  }
  return false;
}

bool _alwaysReturns(Statement statement) {
  if (statement is ReturnStatement) return true;
  return statement is Block && statement.statements.isNotEmpty && statement.statements.last is ReturnStatement;
}

bool _contains(AstNode parent, AstNode child) => parent.offset <= child.offset && child.end <= parent.end;

extension on Expression {
  bool get isMounted {
    return switch (unParenthesized) {
      SimpleIdentifier(name: 'mounted') => true,
      PropertyAccess(target: ThisExpression(), propertyName: SimpleIdentifier(name: 'mounted')) => true,
      _ => false,
    };
  }

  bool get isNotMounted {
    return switch (unParenthesized) {
      PrefixExpression(operator: Token(type: TokenType.BANG), :final operand) => operand.isMounted,
      _ => false,
    };
  }
}

extension on ClassDeclaration {
  /// Returns a list of all asynchronous methods in the class.
  List<MethodDeclaration> get asyncMethods =>
      members.whereType<MethodDeclaration>().where((method) => method.body.isAsynchronous).toList();
}
