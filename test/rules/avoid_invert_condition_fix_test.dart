import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/fixes/avoid_invert_condition_fix.dart';

void main() {
  group('swappedComparisonOperatorLexeme', () {
    test('keeps equality operators unchanged', () {
      expect(swappedComparisonOperatorLexeme(TokenType.EQ_EQ), '==');
      expect(swappedComparisonOperatorLexeme(TokenType.BANG_EQ), '!=');
    });

    test('swaps strict ordering operators', () {
      expect(swappedComparisonOperatorLexeme(TokenType.GT), '<');
      expect(swappedComparisonOperatorLexeme(TokenType.LT), '>');
    });

    test('swaps non-strict ordering operators', () {
      expect(swappedComparisonOperatorLexeme(TokenType.GT_EQ), '<=');
      expect(swappedComparisonOperatorLexeme(TokenType.LT_EQ), '>=');
    });

    test('returns null for unsupported operators', () {
      expect(swappedComparisonOperatorLexeme(TokenType.AMPERSAND_AMPERSAND), isNull);
    });
  });
}
