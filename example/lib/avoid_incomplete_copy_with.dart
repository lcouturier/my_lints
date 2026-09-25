class User {
  final String name;
  final String firstName;
  final int age;

  User({required this.name, required this.firstName, required this.age});

  User copyWith({String? name, String? firstName, int? age}) {
    return User(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age ?? this.age);
  }
}

class User2 {
  final String name;
  final String firstName;
  final int age;

  User2({required this.name, required this.firstName, required this.age});

  // LINT: no `age` parameter, the field cannot be changed.
  User2 copyWith({String? name, String? firstName}) {
    return User2(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age);
  }
}

class User3 {
  final String name;
  final int age;

  User3({required this.name, required this.age});

  // LINT: detected even when the body is not a single return statement.
  User3 copyWith({String? name}) {
    final result = User3(name: name ?? this.name, age: age);
    return result;
  }
}

class User4 {
  final String name;
  final int age;

  User4({required this.name, required this.age});

  // OK: propagation style other than `field ?? this.field`.
  User4 copyWith({String? name, int? age}) {
    return User4(name: name == null ? this.name : name, age: age ?? this.age);
  }
}
