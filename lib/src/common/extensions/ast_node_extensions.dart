import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions/list_extensions.dart';

extension AstNodeExtensions on AstNode {
  /// Returns a tuple containing a boolean and an ancestor node of type [T].
  ///
  /// Traverses up the AST from the current node, checking each ancestor node
  /// to see if it satisfies the given [predicate]. If a node of type [T]
  /// that matches the [predicate] is found, returns `(true, node)`.
  /// If no such node is found, returns `(false, null)`.
  ///
  /// - [predicate]: A function that evaluates whether a node of type [T]
  ///   matches certain criteria.
  ///
  /// - Returns: A tuple `(true, node)` if an ancestor node of type [T]
  ///   satisfying the [predicate] is found, otherwise `(false, null)`.
  (bool, T?) getAncestor<T extends AstNode>(bool Function(T) predicate) {
    AstNode? node = this;
    while (node != null) {
      if (node is T && predicate(node)) {
        return (true, node);
      }
      node = node.parent;
    }
    return (false, null);
  }

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
