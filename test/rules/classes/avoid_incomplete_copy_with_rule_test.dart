import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/avoid_incomplete_copy_with_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidIncompleteCopyWithRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = AvoidIncompleteCopyWithRule();

      expect(rule.diagnosticCode.name, 'avoid_incomplete_copy_with');
      expect(rule.diagnosticCode.problemMessage, 'copyWith method is missing parameters');
      expect(rule.diagnosticCode.correctionMessage, 'Add missing parameters {0} to copyWith');
    });

    test('reports missing parameters in copyWith', () {
      final diagnostics = runAnalysisRule(
        AvoidIncompleteCopyWithRule(),
        '''
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  User copyWith({String? name}) {
    return User(name: name ?? this.name, age: age);
  }
}
''',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report when all fields are covered', () {
      final diagnostics = runAnalysisRule(
        AvoidIncompleteCopyWithRule(),
        '''
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  User copyWith({String? name, int? age}) {
    return User(name: name ?? this.name, age: age ?? this.age);
  }
}
''',
      );

      expect(diagnostics, isEmpty);
    });

    test('ignores static and initialized fields when checking copyWith', () {
      final diagnostics = runAnalysisRule(
        AvoidIncompleteCopyWithRule(),
        '''
class User {
  static const int max = 10;
  final String name;
  final bool isValid = true;

  User({required this.name});

  User copyWith({String? name}) {
    return User(name: name ?? this.name);
  }
}
''',
      );

      expect(diagnostics, isEmpty);
    });

    test('does not report when copyWith is declared in an extension', () {
      final diagnostics = runAnalysisRule(
        AvoidIncompleteCopyWithRule(),
        '''
class User {
  final String name;

  User(this.name);
}

extension UserCopy on User {
  User copyWith({String? name}) {
    return User(name ?? this.name);
  }
}
''',
      );

      expect(diagnostics, isEmpty);
    });
  });
}
