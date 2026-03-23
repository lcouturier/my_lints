import 'package:flutter/foundation.dart';

void foo(void Function() f) {
  f();
}

void bar(VoidCallback f) {
  f();
}

void other(int Function() f) {
  final result = f();
  print(result);
}
