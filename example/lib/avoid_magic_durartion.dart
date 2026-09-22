// ignore_for_file: unused_local_variable

void foo() {
  final result = Duration(seconds: 1);
}

const fiveSeconds = 5;

void bar() {
  final result = Duration(days: 0);
  final result2 = Duration(
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
    microseconds: 0,
  );

  final result3 = Duration(seconds: 5);
  final result4 = Duration(seconds: fiveSeconds);
}
