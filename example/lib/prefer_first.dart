void foo() {
  final list = [1, 2, 3];
  final first = list[0]; // LINT
  final firstElement = list.elementAt(0); // LINT
  final second = list[1];
  print(first);
  print(firstElement);
  print(second);
}

void bar() {
  final list = [1, 2, 3];
  final first = list[list.length - 1]; // LINT
  final firstElement = list.elementAt(list.length - 1); // LINT
  final second = list[1];
  print(first);
  print(firstElement);
  print(second);
}
