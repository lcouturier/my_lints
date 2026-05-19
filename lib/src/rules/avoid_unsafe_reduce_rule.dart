import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AvoidUnsafeReduceRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unsafe_reduce',
    'Avoid unsafe reduce usage',
    correctionMessage: 'Provide a condition to ensure that reduce is not called on an empty iterable.',
  );

  AvoidUnsafeReduceRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);

    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnsafeReduceRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'reduce') return;

    final target = node.target;
    if (target == null) return;

    if (target is MethodInvocation) {
      rule.reportAtNode(node);
      return;
    }

    if (_isSafe(node, target)) return;

    rule.reportAtNode(node);
  }

  bool _isSafe(MethodInvocation node, Expression target) {
    return _hasSafeIfGuard(node, target) ||
        _hasConditionaGuard(node, target) ||
        _hasEarlyReturnGuard(node, target) ||
        _hasAssertGuard(node, target);
  }

  // ignore: unused_element
  bool _hasConditionaGuard(MethodInvocation node, Expression target) {
    if (node.parent case ConditionalExpression(
      condition: PrefixedIdentifier(
        prefix: SimpleIdentifier(name: final prefixName),
        identifier: SimpleIdentifier(name: 'isNotEmpty'),
      ),
      thenExpression: MethodInvocation(methodName: SimpleIdentifier(name: 'reduce')),
    ) when prefixName == target.toSource()) {
      return true;
    }
    if (node.parent case ConditionalExpression(
      condition: PrefixedIdentifier(
        prefix: SimpleIdentifier(name: final prefixName),
        identifier: SimpleIdentifier(name: 'isEmpty'),
      ),
      elseExpression: MethodInvocation(methodName: SimpleIdentifier(name: 'reduce')),
    ) when prefixName == target.toSource()) {
      return true;
    }

    return false;
  }

  bool _hasAssertGuard(MethodInvocation node, Expression target) {
    final statement = node.thisOrAncestorOfType<Statement>();
    final block = node.thisOrAncestorOfType<Block>();

    if (statement == null || block == null) return false;

    final statements = block.statements;
    final index = statements.indexOf(statement);

    if (index <= 0) return false;

    for (var i = 0; i < index; i++) {
      final previous = statements[i];

      if (previous case AssertStatement(condition: final condition)) {
        if (_containsNotEmptyCheck(condition, target)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _hasSafeIfGuard(AstNode node, Expression target) {
    AstNode? current = node.parent;

    while (current != null) {
      if (current is IfStatement) {
        if (_containsNotEmptyCheck(current.expression, target)) {
          return true;
        }
      }

      current = current.parent;
    }

    return false;
  }

  bool _hasEarlyReturnGuard(MethodInvocation node, Expression target) {
    final statement = node.thisOrAncestorOfType<Statement>();
    final block = node.thisOrAncestorOfType<Block>();

    if (statement == null || block == null) return false;

    final statements = block.statements;
    final index = statements.indexOf(statement);

    if (index <= 0) return false;

    for (var i = 0; i < index; i++) {
      final previous = statements[i];

      if (previous case IfStatement(expression: final expression, thenStatement: ReturnStatement())) {
        if (_containsEmptyCheck(expression, target)) {
          return true;
        }
      }

      if (previous case IfStatement(
        expression: final expression,
        thenStatement: Block(statements: final nestedStatements),
      )) {
        final hasReturn = nestedStatements.any((e) => e is ReturnStatement);

        if (hasReturn && _containsEmptyCheck(expression, target)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _containsNotEmptyCheck(Expression expression, Expression target) {
    final expr = expression.unParenthesized;

    return switch (expr) {
      PrefixExpression(operator: Token(type: TokenType.BANG), operand: final operand) => _containsEmptyCheck(
        operand,
        target,
      ),

      _ => _containsEmptyCheck(expr, target),
    };
  }

  bool _containsEmptyCheck(Expression expression, Expression target) {
    final expr = expression.unParenthesized;

    return switch (expr) {
      PropertyAccess(target: final t?, propertyName: final p) =>
        _sameTarget(t, target) && (p.name == 'isEmpty' || p.name == 'isNotEmpty'),

      PrefixedIdentifier(prefix: final p, identifier: final id) =>
        _sameTarget(p, target) && (id.name == 'isEmpty' || id.name == 'isNotEmpty'),

      BinaryExpression(leftOperand: final left, rightOperand: final right, operator: final op) =>
        (op.type == TokenType.AMPERSAND_AMPERSAND || op.type == TokenType.BAR_BAR) &&
            (_containsEmptyCheck(left, target) || _containsEmptyCheck(right, target)),

      _ => false,
    };
  }

  bool _sameTarget(Expression a, Expression b) {
    final aElement = _extractElement(a);
    final bElement = _extractElement(b);

    if (aElement != null && bElement != null) {
      return aElement == bElement;
    }

    return a.toSource() == b.toSource();
  }

  Element? _extractElement(Expression expr) {
    return switch (expr) {
      SimpleIdentifier() => expr.element,
      PrefixedIdentifier() => expr.element,
      _ => null,
    };
  }
}
