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
  const int borne = 50;
  int result = 0 + borne;
  print(result.toString());
  String value = "";
  if ((0 != result) && ("" == value)) {
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

int bar() {
  return 42;
}

bool baz(int x) {
  return x > 0;
}


void foo7() {
  bool a = true;
  bool b = false;
  bool c = true;
  bool d = false;
  bool e = true;
  // ignore: dead_code
  if (!(a && b) && (c || d && e) && baz(bar())) {
    print("complicated condition");
  }
}