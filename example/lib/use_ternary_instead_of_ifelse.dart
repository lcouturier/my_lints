int foo(bool condition) {
  if (condition) {
    return 1;
  } else {
    return 0;
  }
}

int foo2(bool condition) {
  if (condition)
    return 1;
  else
    return 0;
}

int bar(bool condition) {
  return condition ? 1 : 0;
}
