Future<int> uselessAsync() async {
  return 42;
}

Future<int> usefulAsync() async {
  await Future.delayed(Duration(seconds: 1));
  return 42;
}

class MyClass {
  Future<int> uselessAsync() async {
    return 42;
  }

  Future<int> usefulAsync() async {
    await Future.delayed(Duration(seconds: 1));
    return 42;
  }
}
