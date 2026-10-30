import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions/class_declaration_extensions.dart';

/// A rule that reports classes with `Optional` fields that also have a `copyWith` method.
///
/// When a class has a `copyWith` method, using `Optional` fields breaks the standard
/// pattern where null means "keep the existing value". Use `ValueGetter<T>` instead
/// when you need to distinguish between "no change" and "explicit null".
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class Person {
///   final String name;
///   final Optional<String?> firstName;
///   final int age;
///
///   Person({required this.name, required this.firstName, required this.age});
///
///   Person copyWith({String? name, String? firstName, int? age}) {
///     return Person(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age ?? this.age);
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class Person {
///   final String name;
///   final ValueGetter<String?> firstName;
///   final int age;
///
///   Person({required this.name, required this.firstName, required this.age});
///
///   Person copyWith({String? name, ValueGetter<String?>? firstName, int? age}) {
///     return Person(name: name ?? this.name, firstName: firstName != null ? firstName() : this.firstName, age: age ?? this.age);
///   }
/// }
/// ```
class AvoidOptionalInCopyWithRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_optional_in_copy_with',
    'Classes with copyWith should not use Optional fields',
    correctionMessage: 'Use ValueGetter<T> instead of Optional<T>',
  );

  AvoidOptionalInCopyWithRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidOptionalInCopyWithRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isDataClass: true)) {
      final hasCopyWith = node.members.any((member) => member is MethodDeclaration && member.name.lexeme == 'copyWith');
      if (!hasCopyWith) return;

      for (final member in node.members.whereType<FieldDeclaration>().expand((e) => e.fields.variables)) {
        if (_fieldHasOptionalType(member)) {
          rule.reportAtToken(member.name);
        }
      }
    }
  }

  bool _fieldHasOptionalType(VariableDeclaration field) {
    return switch (field.parent) {
      VariableDeclarationList(:final type) when type?.type?.isOptionalType == true => true,
      _ => false,
    };
  }
}

extension on DartType {
  bool get isOptionalType {
    return switch (this) {
      InterfaceType(:final element) when element.name == 'Optional' => true,
      _ => false,
    };
  }
}
