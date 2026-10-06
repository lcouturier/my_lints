import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_throw_literal_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidThrowLiteralRule', () {
    test('reports throwing a literal', () {
      expect(runAnalysisRule(AvoidThrowLiteralRule(), "void fail() { throw 'error'; }"), hasLength(1));
    });

    test('does not report throwing an exception instance', () {
      expect(runAnalysisRule(AvoidThrowLiteralRule(), "void fail() { throw StateError('error'); }"), isEmpty);
    });
  });
}
