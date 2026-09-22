/// Avoid assignation in condition example
/// This example shows how to use the `AvoidAssignationInConditionRule` to detect and report assignations in conditions.
///
///
///

int compute() {
  int a = 0;
  if ((a = 5) == 7) {
    print('This is an assignation in condition.');
  }
  return a;
}

int compute2() {
  // ignore: unused_local_variable
  int a = 0;
  return ((a = compute()) == 7) ? 7 : 0;
}

void main() {
  int a = 0;
  if ((a = compute()) == 7) {
    print(a);
    print('This is an assignation in condition.');
  }
}

void main2() {
  int a = 0;
  while ((a = compute()) < 10) {
    print(a);
    print('This is an assignation in condition.');
  }
}
