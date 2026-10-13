---
name: dart3-patterns
description: "Encourager des patterns Dart 3 lisibles pour décomposer des valeurs, exprimer des conditions et traiter exhaustivement des types."
---

# Patterns du langage Dart 3

Utilise ce guide pour écrire, refactoriser ou relire du code Dart qui peut
bénéficier des patterns introduits avec Dart 3. Préfère-les aux vérifications
de type, aux casts et aux décompositions manuelles lorsqu'ils rendent
l'intention plus claire, sans forcer leur emploi dans du code déjà simple.

## Vérifier la compatibilité

Avant d'introduire un pattern, vérifie la contrainte du SDK dans
`pubspec.yaml` et les versions Dart ciblées par le projet. Les patterns
nécessitent Dart 3 ; ne relève pas la version minimale du SDK sans demande
explicite et sans vérifier les conséquences sur les utilisateurs du package.

## Choisir le bon pattern

- **Déclaration ou affectation** : décompose une valeur composée quand ses
  éléments sont utilisés séparément.
- **`if-case`** : combine une condition et une vérification de forme ou de type
  qui déclare des variables utiles dans le corps.
- **`switch` ou switch expression** : traite plusieurs variantes d'une valeur
  avec des branches distinctes. Privilégie un switch exhaustif pour les types
  scellés (`sealed`) et les énumérations.
- **Pattern de record** : décompose un record par position ou par nom. Pour
  choisir entre record et classe, suis aussi le guide
  [dart-records](../dart-records/SKILL.md).
- **Patterns de liste ou de map** : vérifie et décompose la structure d'une
  collection en une seule opération, notamment avec `...` pour le reste.
- **Pattern d'objet** : vérifie le type et extrait des propriétés exposées par
  l'objet.
- **`when`** : ajoute une condition à un case lorsque la forme seule ne suffit
  pas à déterminer la branche.

## Préférer la décomposition directe

Quand plusieurs valeurs d'un record sont nécessaires, décompose-les au lieu de
multiplier les accès positionnels.

```dart
final (:name, :age) = user;
print('$name a $age ans');
```

Pour la forme et la valeur d'une collection, utilise un pattern plutôt qu'une
suite d'indexations et de contrôles de longueur.

```dart
if (values case [final first, ..., final last]) {
  print('Premier : $first, dernier : $last');
}
```

N'utilise pas de pattern si un accès unique, déjà évident et sûr, est plus
simple que la décomposition.

## Combiner test et extraction

`if-case` permet de tester une forme et de l'extraire sans cast séparé ni
variable temporaire inutile.

```dart
if (json case {'user': {'name': String name}}) {
  print('Utilisateur : $name');
}
```

Un pattern objet peut associer le type à la propriété dont la valeur est
nécessaire :

```dart
if (value case Circle(radius: final radius)) {
  print('Rayon : $radius');
}
```

Utilise un garde `when` seulement pour une contrainte métier ou une condition
qui n'est pas exprimée par le pattern lui-même.

```dart
final category = switch (statusCode) {
  < 400 => 'success',
  >= 400 && < 500 => 'client error',
  >= 500 => 'server error',
};
```

## Traiter les variantes de façon exhaustive

Pour une hiérarchie fermée, déclare la base `sealed` lorsque le modèle doit
limiter ses sous-types, puis laisse le compilateur vérifier la couverture des
variantes.

```dart
sealed class Result {}

class Success extends Result {
  Success(this.value);

  final String value;
}

class Failure extends Result {
  Failure(this.message);

  final String message;
}

String describe(Result result) => switch (result) {
      Success(value: final value) => value,
      Failure(message: final message) => 'Erreur : $message',
    };
```

Évite un branchement générique `_` dans un switch de type fermé lorsqu'il
masquerait l'ajout futur d'une variante. Garde `_` pour un vrai cas par défaut,
notamment lorsque le domaine est ouvert ou que les autres valeurs n'ont pas
d'importance.

## Garder les patterns lisibles

- N'imbrique pas plusieurs niveaux de patterns si leur lecture devient plus
  difficile qu'une décomposition en étapes ou qu'une fonction nommée.
- Évite les patterns redondants : ne répète pas un contrôle déjà garanti par le
  contexte, le type statique ou une branche extérieure.
- Donne des noms précis aux variables extraites ; utilise `_` quand une valeur
  n'est pas utilisée.
- Choisis entre switch statement et switch expression selon le besoin : une
  expression pour produire une valeur, une instruction pour effectuer des
  actions de branches.
- Ne remplace pas automatiquement toute chaîne de `if` par un `switch`.
  Préserve une structure conditionnelle simple lorsqu'elle exprime mieux une
  succession de conditions indépendantes.
- Évite les switch expressions imbriquées. Si elles nuisent à la lecture,
  extrais une fonction ou une variable intermédiaire et respecte les règles
  d'analyse activées dans le projet.
- Vérifie que les patterns de map tiennent compte des clés effectivement
  requises ; si l'entrée est externe ou non fiable, traite aussi explicitement
  le cas où sa forme ne correspond pas.

## Vérification avant de livrer

1. Le code utilise-t-il effectivement une fonctionnalité de patterns Dart 3,
   et le SDK minimal du projet la prend-il en charge ?
2. Le pattern rend-il l'intention plus claire qu'une condition, un cast, des
   indexations ou des accès répétés ?
3. Les valeurs extraites sont-elles utilisées et nommées clairement ?
4. Le traitement des types fermés est-il exhaustif sans défaut qui masquerait
   une nouvelle variante ?
5. Les cas où la forme ne correspond pas sont-ils traités selon le contrat
   d'entrée ?
6. Le code respecte-t-il les règles d'analyse et les conventions du dépôt ?
