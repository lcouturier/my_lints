import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

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
    final parent = node.parent;
    if (parent is! ClassDeclaration) return;

    if (node case MethodDeclaration(:final body, :final returnType) when node.isStatic && returnType != null) {
      final expression = body.expression;
      if (expression case InstanceCreationExpression(:final constructorName)) {
        final parentName = parent.name.lexeme;

        if (parentName == constructorName.type.name.lexeme) {
          rule.reportAtToken(node.name);
        }
      }
    }
  }
}
