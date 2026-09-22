enum MyEnum { a, b, c }

void foo() {
  final values = MyEnum.values;
  final value = values[1];
  print(value);
}

void bar() {
  // PrefixedIdentifier
  final value = MyEnum.values[1];
  print(value);
}
