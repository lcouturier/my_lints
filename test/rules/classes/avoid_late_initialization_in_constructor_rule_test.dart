import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/classes/avoid_late_initialization_in_constructor_rule.dart';

import '../../rule_test_harness.dart' show registeredNodeTypes, runAnalysisRule;

void main() {
  group('AvoidLateInitializationInConstructorRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = AvoidLateInitializationInConstructorRule();

      expect(rule.diagnosticCode.name, 'avoid_late_initialization_in_constructor');
      expect(rule.diagnosticCode.problemMessage, 'Avoid late fields initialized in constructor');
      expect(
        rule.diagnosticCode.correctionMessage,
        'Use constructor parameters or initializer lists instead of late fields',
      );
    });

    test('reports late fields assigned in constructor body', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name;
  late int age;

  User(String n, int a) {
    name = n;
    age = a;
  }
}
''');

      expect(diagnostics, hasLength(2));
    });

    test('reports late fields assigned in initializer list', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name;
  late int age;

  User(String n, int a) : name = n, age = a;
}
''');

      expect(diagnostics, hasLength(2));
    });

    test('does not report late fields with initializers', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name = 'default';
  late int age = 0;
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report late fields not assigned in constructor', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name;
  late int age;

  User();

  void initialize() {
    name = 'John';
    age = 30;
  }
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report static late fields', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  static late String name;

  User(String n) {
    name = n;
  }
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report regular (non-late) fields', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  String name;
  int age;

  User(this.name, this.age);
}
''');

      expect(diagnostics, isEmpty);
    });

    test('does not report final fields', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  final String name;
  final int age;

  User(this.name, this.age);
}
''');

      expect(diagnostics, isEmpty);
    });

    test('handles multiple constructors correctly', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name;
  late int age;

  User(String n, int a) {
    name = n;
    age = a;
  }

  User.named({required String n, required int a}) {
    name = n;
    age = a;
  }
}
''');

      expect(diagnostics, hasLength(2));
    });

    test('does not report when field is assigned in one constructor but not another', () {
      final diagnostics = runAnalysisRule(AvoidLateInitializationInConstructorRule(), '''
class User {
  late String name;
  late int age;

  User(String n, int a) {
    name = n;
    age = a;
  }

  User.empty();
}
''');

      // Should still report since it's assigned in at least one constructor
      expect(diagnostics, hasLength(2));
    });

    test('registers FieldDeclaration node type', () {
      final rule = AvoidLateInitializationInConstructorRule();
      final nodeTypes = registeredNodeTypes(rule);
      expect(nodeTypes, contains('FieldDeclaration'));
    });
  });
}
