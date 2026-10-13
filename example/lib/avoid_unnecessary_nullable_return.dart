// Example of avoid_unnecessary_nullable_return rule

// ❌ Bad: Function with nullable return type that never returns null
String? getName() {
  return 'John';
}

// ❌ Bad: Method with nullable return type that never returns null
class Person {
  String? getName() {
    return 'John';
  }
}

// ✅ Good: Non-nullable return type
String getNameGood() {
  return 'John';
}

// ✅ Good: Nullable return type that can return null
String? getNameOrNull(bool shouldBeNull) {
  if (shouldBeNull) {
    return null;
  }
  return 'John';
}

// ✅ Good: Abstract method (no body to analyze)
abstract class AbstractPerson {
  String? getName();
}

// ✅ Good: Method that overrides another method
abstract class BasePerson {
  String? getName();
}

class Employee extends BasePerson {
  @override
  String? getName() {
    return 'John';
  }
}

// ✅ Good: copyWith method (pattern convention)
class Data {
  final String name;
  Data({required this.name});

  Data? copyWith({String? name}) {
    return Data(name: name ?? this.name);
  }
}
