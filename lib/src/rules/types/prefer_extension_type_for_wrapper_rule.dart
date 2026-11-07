import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prefers extension types over classes that wrap a single value.
///
/// An extension type (Dart 3) wraps a value without any runtime allocation,
/// unlike a regular class that boxes the value. When a class exposes exactly
/// one final instance field initialized by its constructor, it can usually be
/// replaced by an extension type for zero-cost abstraction.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class UserId {
///   final String value;
///   const UserId(this.value);
///   bool get isValid => value.isNotEmpty;
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// extension type UserId(String value) {
///   bool get isValid => value.isNotEmpty;
/// }
/// ```
class PreferExtensionTypeForWrapperRule extends AnalysisRule {
  PreferExtensionTypeForWrapperRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'prefer_extension_type_for_wrapper',
    'Use an extension type instead of a class that wraps a single value.',
    correctionMessage: 'Wrap this value in an extension type.',
    severity: ErrorSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferExtensionTypeForWrapperRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip abstract classes — they cannot be extension types.
    if (node.abstractKeyword != null) return;

    // Skip classes that extend another class (only Object is allowed).
    if (node.extendsClause != null) return;

    // Skip classes that implement other interfaces.
    if (node.implementsClause != null) return;

    // Exactly one non-static instance field declaration.
    final fields = node.members.whereType<FieldDeclaration>().where((f) => !f.isStatic).toList();
    if (fields.length != 1) return;

    final variables = fields.first.fields.variables;
    if (variables.length != 1) return;

    final variable = variables.first;
    if (!variable.isFinal) return;

    final fieldName = variable.name.lexeme;

    // The constructor must initialize the field (this.field or initializer list).
    bool initializesField = false;
    for (final ctor in node.members.whereType<ConstructorDeclaration>()) {
      for (final init in ctor.initializers) {
        if (init is ConstructorFieldInitializer && init.fieldName.name == fieldName) {
          initializesField = true;
        }
      }
      for (final param in ctor.parameters.parameters) {
        if (param is FieldFormalParameter && param.name.lexeme == fieldName) {
          initializesField = true;
        }
      }
    }

    if (!initializesField) return;

    rule.reportAtNode(node);
  }
}
