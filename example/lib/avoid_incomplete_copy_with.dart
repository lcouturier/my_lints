class Person {
  final String name;
  final String lastName;
  final String email;
  final int age;

  Person(this.name, this.lastName, this.email, this.age);

  Person copyWith({String? name, String? lastName, int? age}) {
    return Person(name ?? this.name, lastName ?? this.lastName, this.email, age ?? this.age);
  }
}
