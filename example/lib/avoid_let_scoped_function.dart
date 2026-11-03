// ignore_for_file: invalid_null_aware_operator

extension ScopedExtension<T> on T? {
  R? let<R>(R Function(T it) block) {
    final self = this;
    if (self != null) {
      return block(self);
    }
    return null;
  }
}

void foo() {
  String? name = "Laurent";
  final result = name.let((it) => it.toUpperCase()) ?? ""; // Lint: avoid_let_scoped_function
  print(result);
}

void bar() {
  String? name = "test";
  final result = name?.toUpperCase() ?? "";
  print(result);
}
