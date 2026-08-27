void exampleFunction({String? nullableParam}) {
  if (nullableParam == null) {
    return;
  }
  print(nullableParam);
}

void bar() {
  exampleFunction();
  exampleFunction(nullableParam: null);
  exampleFunction(nullableParam: "Hello");
}
