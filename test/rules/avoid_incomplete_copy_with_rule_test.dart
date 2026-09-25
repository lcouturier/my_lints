import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/common/rule_visitor_extensions.dart';
import 'package:my_lints/src/rules/avoid_incomplete_copy_with_rule.dart';

void main() {
  group('AvoidIncompleteCopyWithRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = AvoidIncompleteCopyWithRule();

      expect(rule.diagnosticCode.name, 'avoid_incomplete_copy_with');
      expect(rule.diagnosticCode.problemMessage, 'copyWith method is missing parameters');
      expect(rule.diagnosticCode.correctionMessage, 'Add missing parameters {0} to copyWith');
    });
  });

  group('AvoidIncompleteCopyWithRule detection logic', () {
    test('reports nothing when every field has a named parameter', () {
      expect(
        _missingFields('''
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  User copyWith({String? name, int? age}) => User(name: name ?? this.name, age: age ?? this.age);
}
'''),
        isEmpty,
      );
    });

    test('reports the field without a named parameter', () {
      expect(
        _missingFields('''
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  User copyWith({String? name}) => User(name: name ?? this.name, age: age);
}
'''),
        ['age'],
      );
    });

    test('reports regardless of the body shape (intermediate variable)', () {
      expect(
        _missingFields('''
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  User copyWith({String? name}) {
    final result = User(name: name ?? this.name, age: age);
    return result;
  }
}
'''),
        ['age'],
      );
    });

    test('reports regardless of the body shape (multiple returns)', () {
      expect(
        _missingFields('''
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  User copyWith({String? name}) {
    if (name == null) return this;
    return User(name: name, age: age);
  }
}
'''),
        ['age'],
      );
    });

    test('accepts propagation styles other than `field ?? this.field`', () {
      expect(
        _missingFields('''
class User {
  final String name;
  final int age;
  User(this.name, this.age);
  User copyWith({String? name, int? age}) => User(name == null ? this.name : name, age ?? this.age);
}
'''),
        isEmpty,
      );
    });

    test('ignores positional parameters of copyWith', () {
      expect(
        _missingFields('''
class User {
  final String name;
  User(this.name);
  User copyWith([String? name]) => User(name ?? this.name);
}
'''),
        ['name'],
      );
    });

    test('ignores static and initialized fields', () {
      expect(
        _missingFields('''
class User {
  static const int max = 10;
  final String name;
  final bool isValid = true;
  User({required this.name});
  User copyWith({String? name}) => User(name: name ?? this.name);
}
'''),
        isEmpty,
      );
    });

    test('handles copyWith declared in a mixin', () {
      expect(
        _missingFields('''
mixin UserMixin {
  final String name = '';
  final int age;
  UserMixin copyWith({String? name});
}
'''),
        ['age'],
      );
    });

    test('does not throw when copyWith is declared in an extension', () {
      expect(
        () => _missingFields('''
class User {
  final String name;
  User(this.name);
}

extension UserCopy on User {
  User copyWith({String? name}) => User(name ?? this.name);
}
'''),
        returnsNormally,
      );
    });

    test('reports nothing for a class without fields', () {
      expect(
        _missingFields('''
class User {
  User copyWith() => User();
}
'''),
        isEmpty,
      );
    });
  });
}

List<String> _missingFields(String source) {
  final visitor = _RecordingVisitor();
  parseString(content: source).unit.accept(visitor);

  return visitor.missing;
}

class _RecordingVisitor extends CustomAstVisitor {
  final List<String> missing = [];

  @override
  void visitCompilationUnit(CompilationUnit node) => node.visitChildren(this);

  @override
  void visitClassDeclaration(ClassDeclaration node) => node.visitChildren(this);

  @override
  void visitMixinDeclaration(MixinDeclaration node) => node.visitChildren(this);

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) => node.visitChildren(this);

  @override
  void visitCopyWithMethod(MethodDeclaration node, Set<String> fields) {
    missing.addAll(node.missingCopyWithParameters(fields));
  }
}
