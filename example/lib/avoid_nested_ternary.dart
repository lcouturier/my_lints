

void foo() {
  int value = 2;
  String result = value > 0 // LINT
      ? "positive"
      : value < 0
          ? "negative"
          : "zero";
  print(result);
}


void foo2() {
  int value = 2;
  String result = value > 0
      ? "positive"
      : "negative";
  print(result);
}