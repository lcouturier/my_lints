// ignore_for_file: unused_local_variable

enum Status {
  pending(1),
  approved(2),
  rejected(3);

  final int value;
  const Status(this.value);
}

class Dimens {
  static const int screenWidth = 1024;
  static const int screenHeight = 768;

  static const double pi = 3.14159;
}

void foo() {
  const list = [1, 2, 3];
  final x = 42;
  print(x);

  final items = [1, 2, 3];
  print(items);

  for (var i = 0; i < 10; i++) {
    print(i);
  }

  final y = Dimens.pi;
  print(y);

  final duration = Duration(seconds: 5);
  print(duration);

  final date = DateTime(2025, 10, 15);
  print(date);
}
