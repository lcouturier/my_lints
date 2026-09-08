class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  factory Person.from(Person other) {
    return Person(other.name, other.age);
  }

  static Person create(String name, int age) {
    // Lint warning: Prefer using factory constructors instead of static methods for object creation.
    print('Creating a Person using a static method');
    return Person(name, age);
  }

  static Person create2(String name, int age) =>
      // Lint warning: Prefer using factory constructors instead of static methods for object creation.
      Person(name, age);
}
