// ignore_for_file: unused_local_variable

void foo() {
  var otherMap = {'key': 'value'};
  var myMap = Map.from(otherMap); // This should trigger the lint warning.
  var myMap2 = {...otherMap};
}
