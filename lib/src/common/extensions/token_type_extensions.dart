import 'package:analyzer/dart/ast/token.dart';

extension TokenTypeExtensions on TokenType {
  /// Checks if the token type is a comparison operator.
  /// Comparison operators include: `==`, `!=`.
  bool get isComparisonOperator {
    return switch (this) {
      TokenType.EQ_EQ => true,
      TokenType.BANG_EQ => true,
      _ => false,
    };
  }
}
