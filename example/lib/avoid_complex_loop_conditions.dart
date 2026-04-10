void foo(int maxRotationAttempts, bool hasSuccessfulResponse) {
  //LINT
  for (var i = 0; (i < _limit()); i++) {
    print(i);
  }

  // LINT
  for (var i = 0; i < maxRotationAttempts && !hasSuccessfulResponse; i++) {
    print(i);
  }

  for (var i = 0; i < maxRotationAttempts; i++) {
    print(i);
  }
}

int _limit() {
  return 10;
}
