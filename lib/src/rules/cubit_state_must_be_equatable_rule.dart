import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

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
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final CubitStateMustBeEquatableRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element == null) return;

    // 1. Chercher le type Cubit dans la hiérarchie résolue (supertypes)
    InterfaceType? cubitSupertype;
    for (final type in element.allSupertypes) {
      // Dans analyzer 8.0, element correspond à un InterfaceElement
      final superElement = type.element;
      final libraryUri = superElement.library.uri.toString();

      if (superElement.name == 'Cubit' && libraryUri.contains('bloc')) {
        cubitSupertype = type;
        break;
      }
    }

    if (cubitSupertype == null) return;

    // 2. Extraire le type générique T de Cubit<T>
    final typeArguments = cubitSupertype.typeArguments;
    if (typeArguments.isEmpty) return;

    final stateType = typeArguments.first;
    if (stateType is! InterfaceType) return;

    // 3. Vérifier si l'état ou l'un de ses supertypes est Equatable
    final stateElement = stateType.element;
    final stateLibraryUri = stateElement.library.uri.toString();

    final isDirectEquatable = stateElement.name == 'Equatable' && stateLibraryUri.contains('equatable');

    final isSubtypeEquatable = stateType.allSupertypes.any((e) {
      final eLibraryUri = e.element.library.uri.toString();
      return e.element.name == 'Equatable' && eLibraryUri.contains('equatable');
    });

    if (isDirectEquatable || isSubtypeEquatable) return;

    // 4. Déterminer le nœud AST pour l'affichage de l'erreur
    // final targetNode = node.extendsClause?.superclass.typeArguments?.arguments.first ?? node.name;

    rule.reportAtToken(node.name, arguments: [stateType.getDisplayString()]);
  }
}
