import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/avoid_optional_in_copy_with_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidOptionalInCopyWithRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = AvoidOptionalInCopyWithRule();

      expect(rule.diagnosticCode.name, 'avoid_optional_in_copy_with');
      expect(rule.diagnosticCode.problemMessage, 'Classes with copyWith should not use Optional fields');
      expect(rule.diagnosticCode.correctionMessage, 'Use ValueGetter<T> instead of Optional<T>');
    });

    test('reports Optional fields in classes with copyWith', () async {
      final unit = await resolveSource('''
import 'package:optional/optional.dart';

class Person {
  final String name;
  final Optional<String?> firstName;
  final int age;

  Person({required this.name, required this.firstName, required this.age});

  Person copyWith({String? name, String? firstName, int? age}) {
    return Person(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age ?? this.age);
  }
}
''', useExamplePackages: true);
      final diagnostics = runAnalysisRuleOnUnit(AvoidOptionalInCopyWithRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report when Optional is not used in class fields', () async {
      final unit = await resolveSource('''
class Person {
  final String name;
  final String? firstName;
  final int age;

  Person({required this.name, this.firstName, required this.age});

  Person copyWith({String? name, String? firstName, int? age}) {
    return Person(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age ?? this.age);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidOptionalInCopyWithRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report when class does not have copyWith', () async {
      final unit = await resolveSource('''
import 'package:optional/optional.dart';

class Person {
  final String name;
  final Optional<String?> firstName;

  Person({required this.name, required this.firstName});

  Person clone({String? firstName}) {
    return Person(name: name, firstName: firstName != null ? Optional.of(firstName) : this.firstName);
  }
}
''', useExamplePackages: true);
      final diagnostics = runAnalysisRuleOnUnit(AvoidOptionalInCopyWithRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports multiple Optional fields in class with copyWith', () async {
      final unit = await resolveSource('''
import 'package:optional/optional.dart';

class Person {
  final Optional<String?> firstName;
  final Optional<int?> age;

  Person({required this.firstName, required this.age});

  Person copyWith({String? firstName, int? age}) {
    return Person(firstName: firstName != null ? Optional.of(firstName) : this.firstName, age: age ?? this.age);
  }
}
''', useExamplePackages: true);
      final diagnostics = runAnalysisRuleOnUnit(AvoidOptionalInCopyWithRule(), unit);

      expect(diagnostics, hasLength(2));
    });
  });
}
