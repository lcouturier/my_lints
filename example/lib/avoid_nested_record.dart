void foo1() {
  final record = (1, (2, 3));
  print(record);
}

void foo2() {
  final f = (1, 2, 3);
  final record = (1, f);
  print(record);
}

void foo3() {
  final record = (1, 2, 3, 4);
  print(record);
}
