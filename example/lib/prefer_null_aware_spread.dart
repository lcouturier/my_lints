// ignore_for_file: unused_local_variable

void fn() {
  final Set<String>? localSet = <String>{};

  // ignore: unused_local_variable
  final collection = [
    // LINT: Prefer null-aware spread (...?) instead of checking for a potential null value.
    if (localSet != null) ...localSet,
    // LINT: Prefer null-aware spread (...?) with the then branch expression.
    ...localSet != null ? localSet : <String>{},
    // LINT: Prefer null-aware spread (...?) instead of if-null (??).
    ...localSet ?? {},
    // LINT: Prefer null-aware spread (...?) with the else branch expression.
    ...{localSet == null ? {} : localSet},
    // LINT: Prefer null-aware spread (...?) with the else branch expression.
    ...{localSet != null ? localSet : {}},
  ];
}

void bar() {
  final Set<String>? localSet = <String>{};

  // ignore: unused_local_variable
  final collection = [...?localSet, ...?localSet, ...?localSet];
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}

void baz() {
  final Point? p = null;
  final point = Point(1, 2);

  final items = [
    if (p != null) p,
  ]; // LINT: Prefer null-aware spread (...?) instead of checking for a potential null value.
  final others = [?p];
  print(items);
}
