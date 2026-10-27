import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:my_lints/src/common/type_checker.dart';

extension BinaryExpressionExtensions on BinaryExpression {
  /// Returns the receiver of a `x.length == 0` or `x.length != 0` comparison, `null` otherwise.
  ///
  /// Purely syntactic: use [isEmptinessComparison] to also validate that the receiver
  /// actually exposes `isEmpty`/`isNotEmpty`.
  ///
  /// Example:
  /// ```dart
  ///   if (list.length == 0) {} // returns the `list` expression
  /// ```
  Expression? get lengthComparisonTarget => switch (this) {
    BinaryExpression(
      leftOperand: PropertyAccess(propertyName: SimpleIdentifier(name: 'length'), target: final Expression target),
      operator: Token(type: TokenType.EQ_EQ || TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    ) =>
      target,
    BinaryExpression(
      leftOperand: PrefixedIdentifier(
        identifier: SimpleIdentifier(name: 'length'),
        prefix: final SimpleIdentifier target,
      ),
      operator: Token(type: TokenType.EQ_EQ || TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    ) =>
      target,
    _ => null,
  };

  /// Returns `true` when this comparison can safely be rewritten as `isEmpty`/`isNotEmpty`.
  bool get isEmptinessComparison => _supportsIsEmpty(lengthComparisonTarget?.staticType);

  /// The getter replacing this comparison: `isEmpty` for `==`, `isNotEmpty` for `!=`.
  String get emptinessGetterName => operator.type == TokenType.EQ_EQ ? 'isEmpty' : 'isNotEmpty';

  bool get isIndexOfComparedToMinusOne {
    return switch (this) {
      BinaryExpression(
        leftOperand: MethodInvocation(methodName: SimpleIdentifier(name: 'indexOf'), :final target),
        operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
        rightOperand: PrefixExpression(operator: Token(type: TokenType.MINUS), operand: IntegerLiteral(value: 1)),
      ) =>
        target?.staticType?.isDartCoreList ?? false,
      _ => false,
    };
  }
}

bool _supportsIsEmpty(DartType? type) =>
    type is InterfaceType &&
    type.nullabilitySuffix != NullabilitySuffix.question &&
    (type.isDartCoreString || isIterableOrSubclass(type) || isMapOrSubclass(type));
