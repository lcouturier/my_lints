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
  final otherDic = {...list}; // LINT

  final list1 = [
    ...[1, 2],
  ];
  final list2 = [...[]];

  final item = 42;
  final list3 = [
    ...[item],
  ];

  final other = [1, 2, 3];
  final list4 = [
    ...[...other],
  ];

  final last = [
    ...[
      ...[
        ...[...other],
      ],
    ],
  ];
}

final map1 = {'a': 1, 'b': 2};
final map2 = {'c': 3, 'd': 4};
final map3 = Map.from(map1)..addAll(map2);
