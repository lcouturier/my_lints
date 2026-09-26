// ignore_for_file: unused_local_variable

void foo() {
  var otherMap = {'key': 'value'};
  var myMap = Map.from(otherMap); // This should trigger the lint warning.
  var myMap2 = {...otherMap};
}

void foo2() {
  var otherMap = {'key': 'value'};
  var myMap = Map.from(otherMap); // This should trigger the lint warning.
  var myMap2 = {...otherMap};
}

void bar() {
  var map = {'key': 'value'};
  for (final key in map.keys) {
    print(map[key]);
  }
}

void foo3() {
  var otherMap = {'key': 'value'};
  var myMap = Map.of(otherMap); // This should trigger the lint warning.
  var myMap2 = {...otherMap};
}

void foo4() {
  var otherMap = {'key': 'value'};
  var myMap = Map.of(otherMap); // This should trigger the lint warning.
  var myMap2 = {...otherMap};
}

void foo5() {
  var otherMap = [1, 2, 3, 4, 5];
  var myMap = List.of(otherMap)
    ..add(1); // This should trigger the lint warning.
}

void foo6() {
  var myMap = List.from([
    1,
    2,
    3,
    4,
    5,
  ]); // This should trigger the lint warning.
  myMap.add(1);
}
