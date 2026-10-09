import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

/// A rule that enforces that Equatable classes include all their fields in the props getter.
///
/// example:
/// ```dart
/// class Person extends Equatable {
///   final String name;
///   final int age;
///   Person({required this.name, required this.age});
///
///   @override
///   List<Object?> get props => [name]; // Missing 'age' in props
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
    if (node case ClassDeclaration(isEquatable: true, :final fields, members: final members) when fields.isNotEmpty) {
      final propsMethod = members.whereType<MethodDeclaration>().firstWhereOrNull((m) => m.name.lexeme == 'props');
      if (propsMethod case MethodDeclaration(:final propsFields) when propsFields.isNotEmpty) {
        final missing = fields.difference(propsFields).toList()..sort();
        if (missing.isNotEmpty) {
          rule.reportAtToken(propsMethod.name, arguments: [missing.join(', ')]);
        }
        return;
      }

      rule.reportAtToken(node.name, arguments: [fields.join(', ')]);
    }
  }
}

extension on MethodDeclaration {
  Set<String> get propsFields {
    return switch (body) {
      ExpressionFunctionBody(expression: final ListLiteral items) =>
        items.elements.whereType<SimpleIdentifier>().map((id) => id.name).toSet(),
      _ => <String>{},
    };
  }
}
