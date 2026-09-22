void foo() {
  final items = [1, 2, 3, 4, 5, 6];
  final result = items.mapIndexed((index, element) => element * 2);
  print(result);
}

void bar() {
  final items = [1, 2, 3, 4, 5, 6];
  final result = items.mapIndexed((index, element) {
    return element * 2;
  });
  print(result);
}

void barz() {
  final items = [1, 2, 3, 4, 5, 6];
  final result = items.mapIndexed((_, element) {
    return element * 2;
  });
  print(result);
}

extension ListExtensions<E> on List<E> {
  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
    for (var index = 0; index < length; index++) {
      yield convert(index, this[index]);
    }
  }
}
