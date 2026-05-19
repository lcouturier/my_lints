// ignore_for_file: dead_code

void foo() {
  final a = true;
  final b = true;
  if (a && b) {
    // do something
  }
}

void bar() {
  final a = true;
  final b = true;
  final c = false;
  if (a && (b || c)) {
    // do something
  }
}

void baz() {
  final a = true;
  final b = true;
  final c = false;
  final d = true;
  if ((a && b) || (c && d)) {
    // do something
  }
}

void qux() {
  final a = true;
  final b = true;
  final c = false;
  final d = true;
  final e = false;
  if (!(a && (b || c)) || d && e) {
    // do something
  }
}
