void foo(bool? isAdult) {
  print(isAdult == true);
}

bool? isAdult() {
  return null;
}

class Person {
  final String name;
  final bool isAdult;

  Person(this.name, this.isAdult);

  Person copyWith({String? name, bool? isAdult}) {
    return Person(name ?? this.name, isAdult ?? this.isAdult);
  }
}
