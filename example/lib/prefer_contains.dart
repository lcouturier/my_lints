void foo() {
  final list = [1, 2, 3];
  if (list.indexOf(2) == -1) {
    print('not found');
  }

  if (list.indexOf(4) != -1) {
    print('found');
  }
}