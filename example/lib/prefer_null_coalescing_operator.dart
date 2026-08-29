void foo({String? nullableParam}) {
  final result = nullableParam != null
      ? nullableParam
      : "Default Value"; // This should trigger the lint and be replaced with `nullableParam ?? "Default Value"`
  print(result);
}

void bar({String? nullableParam}) {
  final result = nullableParam ?? "Default Value";
  print(result);
}

void baz({String? nullableParam}) {
  final result = nullableParam != null
      ? nullableParam
      : "Default Value"; // This should trigger the lint and be replaced with `nullableParam ?? "Default Value"`
  print(result);
}
