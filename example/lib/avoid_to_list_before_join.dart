// ignore_for_file: my_lints/avoid_magic_numbers,

void foo() {
  final items = [1, 2, 3, 4];
  final value = items
      .map((item) => item.toString())
      .toList()
      .join(', '); // LINT
  print(value);
}

void bar() {
  final items = [1, 2, 3, 4];
  final value = items
      .where((item) => item.isEven)
      .map((item) => item.toString())
      .join(', ');
  print(value);
}

class Person {
  final String name;
  final int age;
  final String? firstName;

  Person(this.name, this.age, [this.firstName]);
}

void baz() {
  final people = [
    Person('Alice', 30, 'Ally'),
    Person('Bob', 25),
    Person('Charlie', 35, 'Chuck'),
  ];

  final names = people
      .where((person) => person.age > 30)
      .map((person) => person.firstName)
      .join(', '); // LINT
  print(names);
}
