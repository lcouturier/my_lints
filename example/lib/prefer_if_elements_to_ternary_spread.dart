// ignore_for_file: unused_local_variable

void foo(bool condition) {
  final list = [1, 2, 3];
  final result = [
    ...[0],
    (condition ? [list.first] : []), // LINT
    condition ? [list.first] : [], // LINT
    ...(condition ? [list.first] : []), // LINT
    ...condition ? [list.first] : [], // LINT
    ...[4, 5],
  ];
}

void bar(bool condition) {
  final list = [1, 2, 3];
  final result = [
    ...[0],
    if (condition) ...[list.first], // LINT
    if (condition) list.first,
    ...[4, 5],
  ];
}
