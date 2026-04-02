void foo() {
  int value = 2;
  if (1 != value) {
    print('1 is not equal to value');
  }
}

void foo2() {
  int value = 2;
  if (value != 1) {
    print('value is not equal to 1');
  }
}

void foo3() {
  String value = "";
  if ("" == value) {
    print('value is equal to 1');
  }
}

void foo4() {
  bool value = false;
  if (true == value) {
    print("value is true");
  }
}

void foo5() {
  bool value = false;
  if (value == value) {
    print("value is true");
  }
}

void foo6() {
  String value = "test";
  if ((value != value) == (value != value)) {
    print("value is true");
  }
}
