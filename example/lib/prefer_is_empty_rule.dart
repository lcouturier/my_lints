void main() {
  final isEmpty = [1, 2, 3].length == 0;
  print(isEmpty);

  final name = "test".length == 0;
  print(name);

  final list = <int>[];
  if (list.length == 0) {
    print('Empty');
  }
  if (list.length != 0) {
    print('Not empty');
  }
}
