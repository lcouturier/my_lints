import 'package:analyzer/dart/ast/token.dart';

extension TokenTypeExtensions on TokenType {
  // Returns the inverted token type and a boolean indicating whether the token was inverted.
  // For example, `==` becomes `!=`, `>` becomes `<=`, and so on. If the token type is not a comparison operator, it returns itself and false.
  (TokenType, bool) get invert {
    return switch (this) {
      TokenType.EQ_EQ => (TokenType.BANG_EQ, true),
      TokenType.BANG_EQ => (TokenType.EQ_EQ, true),
      TokenType.GT => (TokenType.LT_EQ, true),
      TokenType.LT => (TokenType.GT_EQ, true),
      TokenType.GT_EQ => (TokenType.LT, true),
      TokenType.LT_EQ => (TokenType.GT, true),
      TokenType.AMPERSAND_AMPERSAND => (TokenType.BAR_BAR, true),
      TokenType.BAR_BAR => (TokenType.AMPERSAND_AMPERSAND, true),
      _ => (this, false),
    };
  }

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
