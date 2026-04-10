// ignore_for_file: unused_local_variable

void foo(bool flag) {
  final another = [...([]), ...const [], ...<String>[], if (flag) ...<String>[]];
}

void bar(bool flag) {
  final another = [
    ...<String>['some', 'elements'], // Correct, no empty spread
  ];
}
