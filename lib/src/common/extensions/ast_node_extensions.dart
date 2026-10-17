import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions/list_extensions.dart';

extension AstNodeExtensions on AstNode {
  /// Returns the depth of the current node in the AST tree, counted from
  /// the root node, until an ancestor node of the current node satisfies
  /// the given [predicate].
  ///
  /// - [predicate]: A function that evaluates whether a node satisfies
  ///   certain criteria.
  ///
  /// - Returns: The depth of the first node that satisfies the [predicate], or
  ///   the depth of the root node if no such node is found.
  int depth(bool Function(AstNode) predicate) {
    int depth = 0;
    AstNode? current = this;
    while (current != null) {
      if (predicate(current)) {
        depth++;
      }
      current = current.parent;
    }
    return depth;
  }

  /// Instance field names of the class, mixin or extension type declaring this
  /// node, or an empty set when there is no such declaration.
  ///
  /// Since analyzer 10 a `ClassBody` node sits between a declaration and its
  /// members, so the enclosing declaration is not the direct parent anymore.
  Set<String> get enclosingInstanceFieldNames {
    final declaration = thisOrAncestorMatching(
      (node) => node is ClassDeclaration || node is MixinDeclaration || node is ExtensionTypeDeclaration,
    );

    return switch (declaration) {
      final ClassDeclaration declaration => declaration.members.instanceFieldNames,
      final MixinDeclaration declaration => declaration.members.instanceFieldNames,
      final ExtensionTypeDeclaration declaration => declaration.members.instanceFieldNames,
      _ => const <String>{},
    };
  }
}
