extension StringExtensions on String {
  // Checks if a string is in camelCase.
  bool get isCamelCase => RegExp(r'(?<=[a-z])[A-Z]').hasMatch(this);
  // Checks if a string is in PascalCase.
  bool get isPascalCase => RegExp(r'(?<=[A-Z])[a-z]').hasMatch(this);
  // Converts the first letter of a string to uppercase.
  String get firstUpper => substring(0, 1).toUpperCase() + substring(1);

  // Removes all spaces from a string.
  String removeAllSpaces() => replaceAll(' ', '');
  // Checks if a string contains only underscores.
  bool get containsOnlyUnderscores => switch (length) {
    0 => false,
    1 => this == '_',
    2 => this == '__',
    3 => this == '___',
    _ => RegExp(r'^_+$').hasMatch(this),
  };

  // Removes a prefix from a string (defaults to "get").
  String removePrefix([String prefix = 'get']) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  // Converts the first letter of a string to lowercase.
  String get firstLowerCase => substring(0, 1).toLowerCase() + substring(1);
  // Splits a string on uppercase letters.
  List<String> splitOnUppercase() => split(RegExp(r'(?=[A-Z])'));

  // Checks if a string contains any negative patterns.
  // Negative patterns include: "not", "no", "disable", "disabled", "cannot", "cant", "without".
  bool get isNegativeName {
    final words = splitOnUppercase().map((e) => e.toLowerCase());
    return words.any((word) => ['not', 'no', 'disable', 'disabled', 'cannot', 'cant', 'without'].contains(word));
  }
}
