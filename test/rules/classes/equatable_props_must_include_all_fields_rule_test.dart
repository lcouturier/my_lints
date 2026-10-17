import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/fixes/equatable_props_must_include_all_fields_fix.dart';
import 'package:my_lints/src/rules/classes/equatable_props_must_include_all_fields_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('EquatablePropsMustIncludeAllFieldsRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = EquatablePropsMustIncludeAllFieldsRule();

      expect(rule.diagnosticCode.name, 'equatable_props_must_include_all_fields');
      expect(rule.diagnosticCode.problemMessage, 'props getter is missing fields: {0}');
      expect(rule.diagnosticCode.correctionMessage, 'Add missing fields {0} to props');
    });

    test('reports when props is missing fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('does not report when props includes all fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name, age];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('reports when props getter is missing', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('does not report non-Equatable classes', () async {
      final unit = await resolveSource('''
class Person {
  final String name;
  final int age;
  Person({required this.name, required this.age});
}
''');

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('does not report Equatable classes with no fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class EmptyState extends Equatable {
  @override
  List<Object?> get props => [];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('reports multiple missing fields', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  final String email;
  Person({required this.name, required this.age, required this.email});

  @override
  List<Object?> get props => [name];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));
    });

    test('handles props with complex expressions', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [name, age];
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('handles props with super.props..addAll', () async {
      final unit = await resolveSource('''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => super.props..addAll([name, age]);
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), isEmpty);
    });

    test('fix adds missing fields to props', () async {
      const source = '''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  final String email;
  Person({required this.name, required this.age, required this.email});

  @override
  List<Object?> get props => [name];
}
''';

      final result = await applyResolvedFix(
        source,
        EquatablePropsMustIncludeAllFieldsFix.new,
        selectionOffset: source.indexOf('props =>'),
        selectionLength: 'props'.length,
        useExamplePackages: true,
      );

      expect(result, source.replaceFirst('[name]', '[name, age, email]'));
    });

    test('fix adds all fields to empty props', () async {
      const source = '''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [];
}
''';

      final unit = await resolveSource(source, useExamplePackages: true);
      expect(runAnalysisRuleOnUnit(EquatablePropsMustIncludeAllFieldsRule(), unit), hasLength(1));

      final result = await applyResolvedFix(
        source,
        EquatablePropsMustIncludeAllFieldsFix.new,
        selectionOffset: source.indexOf('props =>'),
        selectionLength: 'props'.length,
        useExamplePackages: true,
      );

      expect(result, source.replaceFirst('[]', '[age, name]'));
    });

    test('fix adds missing fields to super.props cascade', () async {
      const source = '''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => super.props..addAll([name]);
}
''';

      final result = await applyResolvedFix(
        source,
        EquatablePropsMustIncludeAllFieldsFix.new,
        selectionOffset: source.indexOf('props =>'),
        selectionLength: 'props'.length,
        useExamplePackages: true,
      );

      expect(result, source.replaceFirst('[name]', '[name, age]'));
    });

    test('fix preserves multiline props formatting', () async {
      const source = '''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [
    name,
  ];
}
''';

      final result = await applyResolvedFix(
        source,
        EquatablePropsMustIncludeAllFieldsFix.new,
        selectionOffset: source.indexOf('props =>'),
        selectionLength: 'props'.length,
        useExamplePackages: true,
      );

      expect(result, source.replaceFirst('    name,\n', '    name,\n    age,\n'));
    });

    test('fix does not edit a class without a props getter', () async {
      const source = '''
import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  Person({required this.name});
}
''';

      final result = await applyResolvedFix(
        source,
        EquatablePropsMustIncludeAllFieldsFix.new,
        selectionOffset: source.indexOf('Person extends'),
        selectionLength: 'Person'.length,
        useExamplePackages: true,
      );

      expect(result, source);
    });
  });
}
