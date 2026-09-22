// ignore_for_file: unused_local_variable, unnecessary_null_comparison

void foo() {
  int? a;
  a ??= 42;
}

void bar() {
  int? b;
  if (b == null) {
    b = 42;
  }
}

void barz() {
  const int c = 42;
  int? b;
  if (b == null) {
    b = c;
  }
}

void qux() {
  int? a;
  int? b;
  if (a == null) {
    b = 42;
  }
}

void baz() {
  int? b;
  if (b == null) {
    print('b is null');
    b = 42;
  }
}
