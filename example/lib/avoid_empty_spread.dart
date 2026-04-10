// ignore_for_file: unused_local_variable

void foo(bool flag) {
  final another = [...([]), ...const [], ...<String>[], if (flag) ...<String>[]];
}

void foo2(bool flag) {
  final Set<String>? localSet = <String>{};

  final collection = [
    // LINT: Prefer null-aware spread (...?) instead of checking for a potential null value.
    if (localSet != null) ...localSet,
    // LINT: Prefer null-aware spread (...?) with the then branch expression.
    ...localSet != null ? localSet : <String>{},
    // LINT: Prefer null-aware spread (...?) instead of if-null (??).
    ...localSet ?? {},
  ];
}

void bar(bool flag) {
  final another = [
    ...<String>['some', 'elements'], // Correct, no empty spread
  ];
}
