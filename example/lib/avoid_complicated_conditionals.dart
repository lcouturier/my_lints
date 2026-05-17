// ignore_for_file: dead_code

void foo() {
  bool a = true;
  bool b = false;
  bool c = true;
  bool d = false;
  bool e = true;

  if (a && b && c && d && e) {
    // LINT
    print("All conditions are true");
  }
}

void bar() {
  int x = 10;
  int y = 20;
  int z = 30;

  if (x > 5 && y < 25 && z == 30) {
    print("Complex condition is true");
  }
}

void baz() {
  String name = "Alice";
  int age = 30;
  bool isActive = true;

  if (name.startsWith("A") && age > 18 && isActive) {
    print("User is active and meets the criteria");
  }
}

void qux() {
  bool isValid = false;
  bool isAdmin = true;
  bool hasPermission = false;

  if (!isValid && isAdmin && !hasPermission) {
    // LINT
    print("User does not have access");
  }
}

void quux() {
  int a = 5;
  int b = 10;
  int c = 15;

  while (((a < b) && (b < c)) && a + b > c) {
    // LINT
    print("Complex numeric condition in while loop");
    break;
  }
}

void corge() {
  int x = 10;
  int y = 20;
  int z = 30;

  do {
    if (x > 5 && y < 25 && !(z == 30)) {
      print("Complex condition is true in do-while loop");
    }
    break;
  } while (true);
}
