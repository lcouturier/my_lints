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

enum Color { red, blue, green }

void foo7() {
  Color color = Color.red;

  if (Color.red == color) {
    // LINT
    print("Rouge");
  }
}

void foo8() {
  final list = [1, 2, 3];

  if (-1 == list.indexOf(5)) {
    print("not found");
  }

  if (-1 != list.indexOf(6)) {
    print('found');
  }

  if (1 != list.indexOf(6)) {
    print('found');
  }
}
