---
name: dart-records
description: Choisir, concevoir et utiliser les records Dart avec des types lisibles, des accès explicites et des limites claires face aux classes.
---

# Records Dart : bonnes pratiques

Utilise ce guide pour écrire ou relire du code Dart qui déclare, renvoie,
transmet ou décompose des records.

## Choisir entre record et classe

Un record est adapté pour regrouper quelques valeurs liées, souvent de façon
locale, sans leur donner de comportement ou d'identité propre. Il convient
notamment à un retour composé simple ou à une valeur intermédiaire.

Préfère une classe lorsque le type représente un concept métier, qu'il a besoin
d'un nom stable, de constructeurs, de méthodes, d'invariants, d'une identité,
ou qu'il constitue une API publique amenée à évoluer. Une classe nommée rend
alors l'intention et le contrat plus explicites.

```dart
({int quotient, int remainder}) divide(int dividend, int divisor) {
  return (
    quotient: dividend ~/ divisor,
    remainder: dividend % divisor,
  );
}
```

Si ce résultat devient un concept réutilisé dans plusieurs couches ou qu'il
acquiert des règles métier, remplace-le par une classe telle que
`DivisionResult`.

## Préférer les champs nommés pour les données descriptives

Les champs nommés rendent l'intention visible à la déclaration et à la lecture.
Privilégie-les pour les records à plusieurs champs, les types de retour et les
contrats qui traversent une limite de fonction ou de fichier.

```dart
typedef UserSummary = ({String name, int age});

final UserSummary user = (name: 'Alice', age: 30);
print(user.name);
```

Un record positionnel reste raisonnable pour un regroupement très court et
évident, en particulier lorsqu'il est décomposé immédiatement. Évite de rendre
un accès difficile à interpréter comme `value.$2` : préfère nommer le champ ou
décomposer le record près de son utilisation.

```dart
final (width, height) = getSize();
final area = width * height;
```

Ne transforme pas un type positionnel en type nommé sans vérifier ses
déclarations, ses valeurs et ses usages : la forme du record fait partie de son
type, et le changement peut casser les appels et les affectations.

## Garder les records simples et plats

Évite les records imbriqués. Leur structure rend les types et les accès plus
difficiles à parcourir. Pour des données hiérarchiques, utilise des classes
nommées. Pour une variable locale temporaire, extraire le record interne peut
clarifier le code, mais ne supprime pas le problème si une structure imbriquée
reste nécessaire dans le contrat de données.

```dart
class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class PlaceSummary {
  const PlaceSummary({required this.name, required this.coordinates});

  final String name;
  final Coordinates coordinates;
}
```

Ne crée pas une extension sur un record pour lui ajouter du comportement.
Lorsque les données ont besoin de méthodes ou d'une API dédiée, donne-leur un
type nommé.

## Garder les valeurs compréhensibles

- Donne aux champs nommés des noms précis et orientés métier.
- Déclare un `typedef` quand une forme de record est répétée ou mérite un nom
  dans les signatures.
- Ne crée pas un alias uniquement pour masquer un tuple ambigu.
- Utilise les patterns de record pour décomposer une valeur lorsque cela
  améliore la lisibilité, sans réutiliser plusieurs fois des accès `$1`, `$2`.
- Rappelle-toi que les records sont immuables : leurs champs ne peuvent pas
  être réaffectés. Cette immutabilité est superficielle ; un objet mutable
  stocké dans un champ peut toujours être modifié.
- N'ajoute pas une couche de record autour d'une seule valeur sans bénéfice de
  lisibilité ou de contrat.

## Règles du dépôt `my_lints`

Lorsque ces règles sont activées dans le projet, respecte également les
diagnostics suivants :

- `prefer_named_record_fields` : préfère des champs nommés aux champs
  positionnels dans les types et les littéraux concernés.
- `avoid_positional_record_field_access` : évite les accès aux champs avec
  `$1`, `$2`, etc.
- `avoid_nested_record` : évite les records imbriqués.
- `avoid_extensions_on_records` : préfère une classe à une extension sur un
  type record.

## Vérification avant de livrer

1. Le record décrit-il un regroupement simple de données, plutôt qu'un concept
   métier avec comportement ou identité ?
2. Les noms des champs et leurs accès permettent-ils de comprendre le code sans
   consulter leur définition ?
3. Le record est-il plat, et sa forme reste-t-elle cohérente entre type,
   valeur et usages ?
4. Si le type est répété ou exposé dans une API, un `typedef` ou une classe
   rendrait-il le contrat plus clair ?
5. L'analyse Dart signale-t-elle l'une des règles du projet relatives aux
   records ?
