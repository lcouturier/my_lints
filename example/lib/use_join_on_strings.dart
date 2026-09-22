void foo() {
  final list = ['a', 'b', 'c'];
  final result = list.join(',');
  print(result);
}

void bar() {
  final list = [1, 2, 3];
  final result = list.join(','); //  LINT
  print(result);
}
