import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/equatable_props.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

/// A rule that reports Equatable classes whose recognized `props` list omits fields.
///
/// Include each instance field in `props` so Equatable compares the complete
/// state of the object.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class Person extends Equatable {
///   final String name;
///   final int age;
///   Person({required this.name, required this.age});
///
///   @override
///   List<Object?> get props => [name];
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class Person extends Equatable {
///   final String name;
///   final int age;
///   Person({required this.name, required this.age});
///
///   @override
///   List<Object?> get props => [name, age];
/// }
/// ```
class EquatablePropsMustIncludeAllFieldsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'equatable_props_must_include_all_fields',
    'props getter is missing fields: {0}',
    correctionMessage: 'Add missing fields {0} to props',
  );

  EquatablePropsMustIncludeAllFieldsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final EquatablePropsMustIncludeAllFieldsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isEquatable: true, :final fields, :final members) when fields.isNotEmpty) {
      final methods = {for (final member in members.whereType<MethodDeclaration>()) member.name.lexeme: member};
      final propsMethod = methods['props'];

      final propsList = propsMethod == null ? null : equatablePropsList(propsMethod);
      if (propsMethod != null && propsList != null) {
        final missing = fields.difference(equatablePropsFields(propsList)).toList()..sort();
        if (missing.isNotEmpty) {
          rule.reportAtToken(propsMethod.name, arguments: [missing.join(', ')]);
        }
        return;
      }

      rule.reportAtToken(node.name, arguments: [fields.join(', ')]);
    }
  }
}
