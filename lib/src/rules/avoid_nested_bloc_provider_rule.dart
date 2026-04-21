//Avoid nested BlocProvider. Consider flattening the structure.

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNestedBlocProviderRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nested_bloc_provider',
    "Avoid nested BlocProvider. Consider flattening the structure.",
    correctionMessage: "Consider using MultiBlocProvider.",
  );

  AvoidNestedBlocProviderRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNestedBlocProviderRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'BlocProvider'))),
    )) {
      final parent = node.thisOrAncestorOfType<InstanceCreationExpression>();
      if (parent case InstanceCreationExpression(
        constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'BlocProvider'))),
      )) {
        rule.reportAtNode(node);
      }
    }
  }
}
