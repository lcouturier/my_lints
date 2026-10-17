import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final int age;
  Person({required this.name, required this.age});

  @override
  List<Object?> get props => [age]; // Missing field: name

  Person copyWith({String? name, int? age}) {
    return Person(name: name ?? this.name, age: age ?? this.age);
  }
}
