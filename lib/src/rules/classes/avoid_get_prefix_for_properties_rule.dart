import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that avoids the `get` prefix in property names.
///
/// This rule reports fields, getters, and setters whose names start with `get`
/// followed by an uppercase letter. Getter and setter syntax already indicates
/// that a member reads or writes a property.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class User {
///   String getName = '';
///   String get getLabel => '';
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class User {
///   String name = '';
///   String label => '';
/// }
/// ```
class AvoidGetPrefixForPropertiesRule extends AnalysisRule {
  static const LintCode code = LintCode('avoid_get_prefix_for_properties', 'Avoid the "get" prefix in property names.');

  AvoidGetPrefixForPropertiesRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFieldDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidGetPrefixForPropertiesRule rule;

  _Visitor(this.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final field in node.fields.variables) {
      if (_hasGetPrefix(field.name.lexeme)) {
        rule.reportAtToken(field.name);
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isGetter && _hasGetPrefix(node.name.lexeme)) {
      rule.reportAtToken(node.name);
    }
  }

  bool _hasGetPrefix(String name) {
    if (!name.startsWith('get') || name.length <= 3) return false;

    final character = name[3];
    return character == character.toUpperCase() && character != character.toLowerCase();
  }
}
