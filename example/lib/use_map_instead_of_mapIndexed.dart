extension IterableExtensions<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(int index, E element) mapper) {
    int index = 0;
    return map((element) => mapper(index++, element));
  }
}

void foo() {
  final list = [1, 2, 3, 4, 5];
  final result = list.mapIndexed((index, element) => element * index);
  print(result);
}

void bar() {
  final list = [1, 2, 3, 4, 5];
  final result = list.mapIndexed((index, element) => element * 2); // LINT
  print(result);
}
