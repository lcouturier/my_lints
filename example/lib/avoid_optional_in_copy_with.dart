import 'package:optional/optional.dart';

class Person {
  final String name;
  // LINT: Classes with copyWith should not use Optional fields
  final Optional<String?> firstName;
  final int age;

  Person({required this.name, required this.firstName, required this.age});

  Person copyWith({String? name, String? firstName, int? age}) {
    return Person(
      name: name ?? this.name,
      firstName: firstName != null ? Optional.of(firstName) : this.firstName,
      age: age ?? this.age,
    );
  }
}

class User {
  final String name;
  final String? firstName;
  final int age;

  User({required this.name, this.firstName, required this.age});

  // OK: No Optional field in class
  User copyWith({String? name, String? firstName, int? age}) {
    return User(name: name ?? this.name, firstName: firstName ?? this.firstName, age: age ?? this.age);
  }
}
