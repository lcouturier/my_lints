void foo() {
  final map = {'key': 'value'};

  final value = map.containsKey('key') ? map['key'] : 'default';
  print(value);
}

void bar() {
  final map = {'key': 'value'};

  final value = map['key'] ?? 'default';
  print(value);
}