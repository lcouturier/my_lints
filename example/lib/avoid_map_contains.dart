void foo() {
  final map = {'hello': 'world'};

  map.keys.contains('hello'); // LINT
}

void bar() {
  final map = {'hello': 'world'};

  map.containsKey('hello');
}
