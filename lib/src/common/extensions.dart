// Extension to check if a class is an Equatable class

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtensions on DartType {
  // Checks if a DartType is a nullable list.
  bool get isNullableList {
    final predicates = [
      () => this is InterfaceType,
      () => element?.name == 'List',
      () => nullabilitySuffix == NullabilitySuffix.question,
    ];

    return predicates.every((e) => e());
  }

  // Checks if a DartType is a subtype of a given type name.
  bool _isSubtypeOfType(String typeName) {
    return element?.displayName == typeName ||
        ((this is InterfaceType) &&
            (this as InterfaceType).allSupertypes.any(
              (e) => e.element.name == typeName,
            ));
  }

  // Returns a cached version of the `_isSubtypeOfType` method.
  bool Function(String) get isSubtypeOfType => _isSubtypeOfType.cache();
}

extension FunctionCacheExtensions<F, R> on R Function(F) {
  // Caches the results of a function call.
  R Function(F) cache() {
    final cache = <F, R>{};
    return (key) => cache[key] ??= this(key);
  }
}

extension RecordTypeExtensions on RecordType {
  // Checks if a record type has both positional and named fields.
  bool get isMixed => positionalFields.isNotEmpty && namedFields.isNotEmpty;
}

bool isNullableType(DartType? type) =>
    type?.nullabilitySuffix == NullabilitySuffix.question;

extension DartTypeNullableExtensions on DartType? {
  bool get isNullable => isNullableType(this);
  // Checks if a type is an Iterable or a subclass of Iterable.
  // bool get isIterableOrSubclass => isIterableOrSubclassCore(this);
  // Checks if a type is nullable.
  // bool get isNullable => isNullableType(this);
  // Checks if a type is a Widget.
  bool get isWidget =>
      this?.getDisplayString(withNullability: false) == 'Widget';

  // Checks if a type is a callback function.
  // bool get isCallbackType {
  //   return toString().startsWith('Null') || _isCallbackType(this);
  // }

  // Checks if a type has a constructor with a given name.
  bool hasConstructor(String name) {
    return (this is InterfaceType) &&
        (this! as InterfaceType).constructors.any((e) => e.name == name);
  }

  // Checks if a DartType is a callback type.
  // bool _isCallbackType(DartType? type) {
  //   return (type is FunctionType &&
  //       (type.returnType is VoidType ||
  //           type.returnType is DynamicType ||
  //           type.parameters.isEmpty));
  // }
}

extension FormalParameterExtension on FormalParameter {
  // Checks if a formal parameter is a boolean.
  bool get isBool =>
      this is SimpleFormalParameter &&
      ((this as SimpleFormalParameter).type?.type?.isDartCoreBool ?? false);

  // Checks if a formal parameter is nullable.
  // bool get isNullable =>
  //     this is SimpleFormalParameter &&
  //     ((this as SimpleFormalParameter).type?.type?.isNullable ?? false);

  // Checks if a formal parameter is dynamic.
  // bool get isDynamic => declaredElement?.type is DynamicType;
}

// extension ExpressionExtensions on Expression {
//   // Extracts field names from a props list literal.
//   List<String> getFieldsFromProps() {
//     if (this is ListLiteral) {
//       return (this as ListLiteral).elements
//           .whereType<SimpleIdentifier>()
//           .map((id) => id.staticElement)
//           .map((e) => e?.displayName ?? '')
//           .toList();
//     }
//     return [];
//   }
// }

extension FunctionBodyExtensions on FunctionBody {
  // Returns the expression from a function body.
  Expression? get expression => switch (this) {
    BlockFunctionBody(:final block) =>
      block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
    ExpressionFunctionBody(:final expression) => expression,
    _ => null,
  };
  // Checks if a function body has a return statement.
  bool get hasReturnStatement {
    return switch (this) {
      final BlockFunctionBody b => b.block.statements.any(
        (e) => e is ReturnStatement,
      ),
      ExpressionFunctionBody _ => true,
      _ => false,
    };
  }

  // Checks if a function body returns `this`.
  bool get hasReturnThis {
    return switch (this) {
      BlockFunctionBody b =>
        b.block.statements.whereType<ReturnStatement>().first.expression
            is ThisExpression,
      ExpressionFunctionBody e => e.expression is ThisExpression,
      _ => false,
    };
  }
}

extension StringExtensions on String {
  // Checks if a string is in camelCase.
  bool get isCamelCase => RegExp(r'(?<=[a-z])[A-Z]').hasMatch(this);
  // Checks if a string is in PascalCase.
  bool get isPascalCase => RegExp(r'(?<=[A-Z])[a-z]').hasMatch(this);
  // Converts the first letter of a string to uppercase.
  String get firstUpper => substring(0, 1).toUpperCase() + substring(1);

  // Removes all spaces from a string.
  String removeAllSpaces() => replaceAll(' ', '');
  // Checks if a string contains only underscores.
  bool get containsOnlyUnderscores => switch (length) {
    0 => false,
    1 => this == '_',
    2 => this == '__',
    3 => this == '___',
    _ => RegExp(r'^_+$').hasMatch(this),
  };

  // Removes a prefix from a string (defaults to "get").
  String removePrefix([String prefix = 'get']) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  // Converts the first letter of a string to lowercase.
  String get firstLowerCase => substring(0, 1).toLowerCase() + substring(1);
  // Splits a string on uppercase letters.
  List<String> splitOnUppercase() => split(RegExp(r'(?=[A-Z])'));
}

extension ListExtensions<E> on List<E> {
  Map<T, List<E>> groupBy<T>(T Function(E) selector) {
    final map = <T, List<E>>{};
    for (final element in this) {
      final key = selector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}

extension TokenTypeExtensions on TokenType {
  (TokenType, bool) get invert {
    return switch (this) {
      TokenType.EQ_EQ => (TokenType.BANG_EQ, true),
      TokenType.BANG_EQ => (TokenType.EQ_EQ, true),
      TokenType.GT => (TokenType.LT_EQ, true),
      TokenType.LT => (TokenType.GT_EQ, true),
      TokenType.GT_EQ => (TokenType.LT, true),
      TokenType.LT_EQ => (TokenType.GT, true),
      TokenType.AMPERSAND_AMPERSAND => (TokenType.BAR_BAR, true),
      TokenType.BAR_BAR => (TokenType.AMPERSAND_AMPERSAND, true),
      _ => (this, false),
    };
  }
}

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
}

extension FormalParameterExtensions on FormalParameter {
  bool get isBuildContext =>
      this is SimpleFormalParameter &&
      (this as SimpleFormalParameter).type != null &&
      (this as SimpleFormalParameter).type.toString() == 'BuildContext';
}
