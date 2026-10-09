import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class CubitStateMustBeEquatableRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'cubit_state_must_be_equatable',
    'L\'état de ce Cubit ({0}) doit hériter de Equatable.',
    correctionMessage: 'Faites hériter la classe d\'état de Equatable.',
  );

  CubitStateMustBeEquatableRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final CubitStateMustBeEquatableRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(
      isCubitClass: true,
      extendsClause: ExtendsClause(superclass: NamedType(typeArguments: TypeArgumentList(arguments: [final firstArg]))),
    )) {
      if (firstArg.type case InterfaceType(isEquatable: false)) {
        rule.reportAtNode(node);
      }
    }
  }
}
