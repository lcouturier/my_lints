import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:my_lints/src/common/extensions.dart';

/// Classe de base pour vos règles personnalisées
abstract class CustomAstVisitor extends SimpleAstVisitor<void> {
  /// Votre méthode custom !
  void visitCopyWithMethod(MethodDeclaration node, Set<String> fields) {}

  /// Votre méthode custom pour les classes Cubit
  void visitCubitClass(ClassDeclaration node) {}

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.isCubitClass) {
      visitCubitClass(node);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Si la méthode s'appelle copyWith, on redirige vers notre méthode custom
    if (node.name.lexeme != 'copyWith') return;

    final fields = node.enclosingInstanceFieldNames;
    if (fields.isEmpty) return;

    visitCopyWithMethod(node, fields);
  }
}

extension CopyWithRegistryExtension on RuleVisitorRegistry {
  /// Enregistre spécifiquement les processeurs pour la méthode copyWith
  void addCopyWithMethod(AnalysisRule rule, CustomAstVisitor visitor) {
    // On enregistre le visiteur sur les déclarations de méthodes
    addMethodDeclaration(rule, visitor);
  }

  void addCubitClass(AnalysisRule rule, CustomAstVisitor visitor) {
    // On enregistre le visiteur sur les déclarations de classes
    addClassDeclaration(rule, visitor);
  }
}
