import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidShadowedExtensionMethodsRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'avoid_shadowed_extension_methods',
    'Avoid shadowing extension methods. Method "{0}" is already defined in the extended class.',
    correctionMessage: 'Use a different method name for "{0}" to avoid shadowing.',
  );

  AvoidShadowedExtensionMethodsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addExtensionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidShadowedExtensionMethodsRule rule;

  _Visitor(this.rule);

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    if (node case ExtensionDeclaration(
      :final members,
      onClause: ExtensionOnClause(extendedType: TypeAnnotation(type: DartType(element: ClassElement(:final methods)))),
    )) {
      final extensionMethods = members.whereType<MethodDeclaration>();

      for (var element in extensionMethods) {
        if (methods.any((m) => m.name == element.name.lexeme)) {
          rule.reportAtToken(element.name, arguments: [element.name.lexeme]);
        }
      }
    }
  }
}
