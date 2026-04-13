// ignore_for_file: unused_local_variable, unused_field

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
  final cow = nullableCow ?? Cow()
    ..moo();
}

void good() {
  final Cow? nullableCow = null;

  final cow2 = nullableCow ?? (Cow()..moo()); // Correct, cascade is called only for the new instance

  final cow3 = (nullableCow ?? Cow())..moo(); // Correct, cascade is called only for the new instance
}
