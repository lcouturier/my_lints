import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/avoid_unchecked_stream_subscriptions_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUncheckedStreamSubscriptionsRule', () {
    test('reports an unchecked stream.listen() call', () async {
      final unit = await resolveSource('''
import 'dart:async';

void main() {
  final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  stream.listen((data) { print(data); });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a stored stream.listen() call', () async {
      final unit = await resolveSource('''
import 'dart:async';

void main() {
  final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  final subscription = stream.listen((data) { print(data); });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an assigned stream.listen() call', () async {
      final unit = await resolveSource('''
import 'dart:async';

void main() {
  final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  StreamSubscription? subscription;
  subscription = stream.listen((data) { print(data); });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports multiple unchecked stream.listen() calls', () async {
      final unit = await resolveSource('''
import 'dart:async';

void main() {
  final stream1 = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  final stream2 = Stream<int>.periodic(Duration(seconds: 2), (i) => i);
  stream1.listen((data) { print(data); });
  stream2.listen((data) { print(data); });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report non-listen method calls', () async {
      final unit = await resolveSource('''
import 'dart:async';

void main() {
  final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  stream.map((i) => i * 2);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report listen on non-stream types', () async {
      final unit = await resolveSource('''
class NotAStream {
  void listen(void Function(int) onData) {}
}

void main() {
  final notAStream = NotAStream();
  notAStream.listen((data) { print(data); });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUncheckedStreamSubscriptionsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
