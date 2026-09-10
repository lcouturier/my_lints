// ignore_for_file: unused_element

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
    if (node.name.lexeme == 'copyWith') {
      final parent = node.parent as ClassDeclaration;

      final fields = parent.fields;
      if (fields.isEmpty) return;
      visitCopyWithMethod(node, fields);
    }
  }
}

extension CopyWithRegistryExtension on RuleVisitorRegistry {
  /// This method registers a rule only for classes that declare a `copyWith` method.
  ///
  /// [rule] The rule to register.
  /// [visitor] The visitor to use for the rule.
  ///
  /// Returns nothing.
  // void addCopyWithMethod(AnalysisRule rule, AstVisitor<void> visitor) {
  //   final conditionalVisitor = _CopyWithClassVisitor(visitor);
  //   addClassDeclaration(rule, conditionalVisitor);
  // }

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

@Deprecated("Use addCopyWithMethod instead")
class _CopyWithClassVisitor extends SimpleAstVisitor<void> {
  final AstVisitor<void> delegate;

  _CopyWithClassVisitor(this.delegate);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Vérifie la présence d'une méthode nommée 'copyWith' dans les membres de la classe
    final hasCopyWith = node.members.whereType<MethodDeclaration>().any((method) => method.name.lexeme == 'copyWith');

    // Si la méthode existe, on transmet le nœud au visiteur de la règle
    if (hasCopyWith) {
      // node.visitChildren(delegate); // ou delegate.visitClassDeclaration(node);
      delegate.visitClassDeclaration(node);
    }
  }
}
