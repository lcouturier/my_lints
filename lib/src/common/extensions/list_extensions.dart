import 'package:analyzer/dart/ast/ast.dart';

extension ListExtensions<E> on List<E> {
  Map<T, List<E>> groupBy<T>(T Function(E) selector) {
    final map = <T, List<E>>{};
    for (final element in this) {
      final key = selector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  List<E> shiftRight(int n) {
    if (isEmpty) return this;
    final length = this.length;
    final shift = n % length;
    if (shift == 0) return List.of(this);

    return [...sublist(length - shift), ...sublist(0, length - shift)];
  }

  List<E> shiftLeft(int n) {
    if (isEmpty) return this;
    final length = this.length;
    final shift = n % length;
    if (shift == 0) return List.of(this);

    return [...sublist(shift), ...sublist(0, shift)];
  }
}

extension ClassMemberListExtensions on List<ClassMember> {
  /// Returns the names of the non-static, non-synthetic fields that can be
  /// provided by a caller. Fields with an initializer are derived state and are
  /// therefore excluded.
  Set<String> get instanceFieldNames => whereType<FieldDeclaration>()
      .where((e) => !e.isStatic)
      .where((e) => !e.isSynthetic)
      .expand((e) => e.fields.variables)
      .where((variable) => variable.initializer == null)
      .map((variable) => variable.name.lexeme)
      .toSet();
}
