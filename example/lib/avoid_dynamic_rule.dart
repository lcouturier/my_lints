void foo(dynamic value) {
  print(value);
}

void bar(Function f) {
  Function other = () {};
  other();
  f();
}
