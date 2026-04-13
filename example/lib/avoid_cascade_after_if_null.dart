// ignore_for_file: unused_local_variable

class Cow {
  void moo() {}
}

class Ranch {
  final Cow? _cow;

  Ranch([Cow? cow])
    // LINT: Cascade expressions without parentheses placed after ?? can lead to unexpected errors.
    //  Try adding parentheses to ensure correct precedence.
    : _cow = cow ?? Cow()
        ..moo();
}

void main() {
  final Cow? nullableCow = null;

  // LINT: Cascade expressions without parentheses placed after ?? can lead to unexpected errors.
  //  Try adding parentheses to ensure correct precedence.
  // ignore: unused_local_variable
  final cow = nullableCow ?? Cow()
    ..moo();
}

void good() {
  final Cow? nullableCow = null;

  final cow = (nullableCow ?? Cow())
    ..moo(); // Correct, parentheses are used before cascade

  final cow2 =
      nullableCow ??
      (Cow()..moo()); // Correct, cascade is called only for the new instance
}
