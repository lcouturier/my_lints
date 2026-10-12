import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that reports static methods returning a direct instance of their class.
///
/// A factory constructor expresses instance creation as part of the class
/// constructor API. This rule recognizes expression-bodied static methods whose
/// expression directly creates an instance of the enclosing class.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyClass {
///   static MyClass create() => MyClass();
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyClass {
///   factory MyClass.create() => MyClass._();
///
///   MyClass._();
/// }
/// ```
class PreferFactoryConstructorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_factory_constructor',
    'Prefer using factory constructors instead of static methods for object creation.',
  );

  PreferFactoryConstructorRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferFactoryConstructorRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final parent = node.thisOrAncestorMatching((node) => node is ClassDeclaration);
    if (parent == null) return;
    final parentName = (parent as ClassDeclaration).name;

    if (node case MethodDeclaration(
      body: FunctionBody(expression: InstanceCreationExpression(:final constructorName)),
      :final returnType,
      isStatic: true,
      isGetter: false,
      isSetter: false,
    ) when returnType != null) {
      if (parentName.lexeme == constructorName.type.name.lexeme) {
        rule.reportAtNode(node);
      }
    }
  }
}
