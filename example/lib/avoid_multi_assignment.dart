class SomeClass {
  String someString = 'some';
  String another = 'another';

  void update(String str) {
    // LINT: Avoid multi assignments. Try moving each assignment to its own line.
    someString = another = str;

    final instance = SomeClass();
    // LINT: Avoid multi assignments. Try moving each assignment to its own line.
    instance.another = someString = str;
  }
}
