// ignore_for_file: unused_local_variable

final values = [1, 2, 3];

void foo() {
  final list = [
    ...[1],
    ...[2, 3],
    ...[
      const [4],
    ],
    ...[values.first],
  ];

  final other = [...list];
}

void foo2() {
  final set = {
    ...{1},
    ...{2, 3},
    ...{
      const {4},
    },
    ...{values.first},
  };
}
