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
  ];
}
