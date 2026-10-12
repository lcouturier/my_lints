// Bad: late fields initialized in constructor body
class UserBad {
  late String name;
  late int age;

  UserBad(String n, int a) {
    name = n;
    age = a;
  }
}

// Bad: late fields initialized in initializer list
class UserBad2 {
  late String name;
  late int age;

  UserBad2(String n, int a) : name = n, age = a;
}

// Good: use constructor parameters
class UserGood {
  final String name;
  final int age;

  UserGood(this.name, this.age);
}

// Good: use named parameters
class UserGood2 {
  final String name;
  final int age;

  UserGood2({required this.name, required this.age});
}

// Good: late with initializer
class UserGood3 {
  late String name = 'default';
  late int age = 0;
}

// Good: late for lazy initialization
class UserGood4 {
  late String _cachedName;

  String get name {
    if (_cachedName.isEmpty) {
      _cachedName = fetchName();
    }
    return _cachedName;
  }

  String fetchName() => 'John';
}

// Good: late not assigned in constructor
class UserGood5 {
  late String name;
  late int age;

  UserGood5();

  void initialize() {
    name = 'John';
    age = 30;
  }
}

// Good: static late fields are allowed
class UserGood6 {
  static late String name;

  UserGood6(String n) {
    name = n;
  }
}
