import 'package:example/prefer_throw_exception_or_error.dart';

int foo() {
  return 5;
}

void bar() {
  print('whatever');
}

Future<int> baz() {
  return Future.value(5);
}

void main() {
  bar();
  // LINT: Avoid ignoring return values.
  //  Try assigning this invocation to a variable and referencing it in your code.
  foo();

  bar2();

  final str = 'Hello there';
  // LINT: Avoid ignoring return values.
  //  Try assigning this invocation to a variable and referencing it in your code.
  str.substring(5);

  final date = new DateTime(2018, 1, 13);
  // LINT: Avoid ignoring return values.
  //  Try assigning this invocation to a variable and referencing it in your code.
  date.add(Duration(days: 1, hours: 23));
}
