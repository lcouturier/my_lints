

void foo() {
  final x = switch (1) {
    1 => switch (2) {
      2 => 'nested',
      _ => 'other',
    },
    _ => 'other',
  };
  print(x);
}