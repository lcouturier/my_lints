void foo() {
  final a = true;
  final b = true;
  final c = true;
  final d = true;
  final e = true;
  final f = true;
  final g = true;
  final h = true;
  final i = true;
  final j = true;

  // Trop de variables (10 variables > maxVariables: 3)
  if (a && b && c && d && e && f && g && h && i && j) {
    // do something
  }

  // Trop de types d'opérateurs différents (&&, ||, ==, >, != = 5 types > maxOperatorTypes: 3)
  final x = 5;
  final y = 10;
  final z = 15;
  if (x > 0 && y < 20 || z == 15 && x != y) {
    // do something
  }

  // Trop de tokens (expression longue)
  if (a && b && c && d && e) {
    // do something
  }

  // Dans une boucle while
  while (a && b && c && d && e && f) {
    break;
  }

  // Dans une boucle do-while
  do {
    break;
  } while (a && b && c && d && e && f);

  // Dans une expression ternaire
  final result = (a && b && c && d && e) ? 1 : 0;
}

class User {
  String? name;
  int? age;
  bool isActive;
  bool hasPermission;
  bool isVerified;

  User(this.name, this.age, this.isActive, this.hasPermission, this.isVerified);
}

void checkUser(User user) {
  // Trop de variables dans un contexte réel (user, name, age, isActive, hasPermission, isVerified = 6 variables > 3)
  if (user != null &&
      user.name != null &&
      user.age != null &&
      user.isActive &&
      user.hasPermission &&
      user.isVerified) {
    // do something
  }
}
