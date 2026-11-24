int sumLengths(List<String> values) =>
    values.fold<int>(0, (total, value) => total + value.length); // LINT

int sumLengthsWithMap(List<String> values) =>
    values.map((value) => value.length).sum;

class Values {
  final List<String> items;
  final String name;

  Values(this.items, this.name);
}

int? sumNullableLengths(Values? values) =>
    values?.items.map((value) => value.length).sum;

// An extension such as package:collection's IterableIntegerExtension is needed.
extension IntegerSum on Iterable<int> {
  int get sum {
    var result = 0;
    for (final value in this) {
      result += value;
    }
    return result;
  }
}
