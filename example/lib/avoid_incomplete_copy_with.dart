class User {
  final String name;
  final String firstName;
  final int age;

  User({required this.name, required this.firstName, required this.age});

  User copyWith({String? name, String? firstName, int? age}) {
    return User(
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
    );
  }
}

class User2 {
  final String name;
  final String firstName;
  final int age;

  User2({required this.name, required this.firstName, required this.age});

  User2 copyWith({String? name, String? firstName}) {
    return User2(
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      age: age, // Missing age field
    );
  }
}
