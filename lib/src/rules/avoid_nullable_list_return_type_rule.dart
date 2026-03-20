import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidNullableListReturnTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_nullable_list_return_type',
    'Avoid nullable list return type',
    correctionMessage: 'Avoid nullable list return type',
  );

  AvoidNullableListReturnTypeRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNullableListReturnTypeRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node case FunctionDeclaration(returnType: var returnType?)) {
      final type = returnType.type;
      if (type?.isNullableList ?? false) {
        rule.reportAtNode(returnType);
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node case MethodDeclaration(returnType: var returnType?)) {
      final type = returnType.type;
      if (type?.isNullableList ?? false) {
        rule.reportAtNode(returnType);
      }
    }
  }
}
