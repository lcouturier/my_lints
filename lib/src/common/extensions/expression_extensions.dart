import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

extension ExpressionExtensions on Expression {
  /// Returns the innermost expression by unwrapping any parenthesized expressions.
  /// For example, for the expression `((a + b))`, this getter will return `a + b`.
  Expression get unWrap {
    var current = this;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }

  bool get isSimpleLiteral => switch (this) {
    IntegerLiteral() || DoubleLiteral() || BooleanLiteral() || NullLiteral() || SimpleStringLiteral() => true,
    _ => false,
  };

  bool get isNegativeOne {
    return switch (this) {
      PrefixExpression(operator: Token(type: TokenType.MINUS), operand: IntegerLiteral(value: 1)) => true,
      _ => false,
    };
  }

  bool get isIndexOfCall {
    return this is MethodInvocation && (this as MethodInvocation).methodName.name == 'indexOf';
  }

  /// Returns the name of the expression if it is a simple identifier, property access or prefixed identifier.
  /// Returns null otherwise.
  /// this.items.reduce(...)
  /// items.reduce(...)
  /// widget.items.reduce(...)
  String? get normalizedName => switch (this) {
    SimpleIdentifier(:final name) => name,
    PropertyAccess(:final propertyName) => propertyName.name,
    PrefixedIdentifier(:final identifier) => identifier.name,
    _ => null,
  };

  /// Checks if the expression is a constant.
  /// This includes:
  /// - Literal values (int, double, bool, null, string)
  /// - Const instance creation expressions
  /// - Any expression that can be evaluated to a constant value
  bool get isConstant {
    final expr = unParenthesized;
    return switch (expr) {
      Literal() => true,
      final InstanceCreationExpression e => e.isConst,
      _ => expr.computeConstantValue() != null,
    };
  }
}
