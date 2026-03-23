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
    'Avoid shadowing extension methods.',
    correctionMessage: 'Use a different method name to avoid shadowing.',
    severity: DiagnosticSeverity.WARNING,
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
      members: final members,
      onClause: ExtensionOnClause(
        extendedType: TypeAnnotation(type: DartType(element: ClassElement(methods: final methods))),
      ),
    )) {
      final extensionMethods = members.whereType<MethodDeclaration>();

      for (var element in extensionMethods) {
        if (methods.any((m) => m.name == element.name.lexeme)) {
          rule.reportAtNode(element);
        }
      }
    }
  }
}
