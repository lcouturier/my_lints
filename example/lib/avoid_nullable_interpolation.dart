void foo() {
  String? username;

  // Totalement valide selon le linter standard Dart !
  // Résultat à l'écran ou dans une API : "Bonjour, null"
  print(
    'Bonjour, $username',
  ); // This should trigger the lint and be replaced with `username ?? 'invité'`
}

void bar() {
  String? username;

  // Correct : Utilisation d'une valeur par défaut ou vérification explicite
  String greeting = 'Bonjour ${username ?? 'invité'}';
  print(greeting);
}
