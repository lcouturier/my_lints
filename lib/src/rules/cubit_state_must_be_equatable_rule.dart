import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/rule_visitor_extensions.dart';

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
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addCubitClass(this, visitor);
  }
}

class _Visitor extends CustomAstVisitor {
  _Visitor(this.rule);

  final CubitStateMustBeEquatableRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final superclassClause = node.extendsClause;
    if (superclassClause == null) return;

    final typeArguments = superclassClause.superclass.typeArguments?.arguments;
    if (typeArguments == null || typeArguments.isEmpty) return;

    final stateType = typeArguments.first.type;
    if (stateType is! InterfaceType) return;

    final isEquatable = stateType.allSupertypes.any((e) {
      return e.element.name == 'Equatable' && e.element.library.identifier.contains('equatable');
    });

    if (isEquatable) return;

    rule.reportAtNode(typeArguments.first, arguments: [stateType.element.name ?? '']);
  }
}
