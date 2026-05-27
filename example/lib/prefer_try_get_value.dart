void foo() {
  final map = {'key': 'value'};

  // LINT: Prefer using tryGetValue instead of containsKey and [].
  final value = map.containsKey('key') ? map['key'] : 'default';
  print(value);
}

void bar() {
  final map = {'key': 'value'};

  final value = map['key'] ?? 'default';
  print(value);
}
