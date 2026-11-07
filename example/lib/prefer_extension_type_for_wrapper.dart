class UserId {
  final String value;
  const UserId(this.value);

  bool get isValid => value.isNotEmpty;
}
