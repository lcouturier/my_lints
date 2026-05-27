// ignore_for_file: unused_local_variable

void foo() {
  final list = [
    ...[1, 2, 3],
    ...[4, 5, 6],
  ];

  final set = {
    ...{1, 2, 3},
    ...{4, 5, 6},
  };

  final oups = [
    ...[1, 2, 3], // LINT
  ];

  final otherList = [...list]; // LINT
}
