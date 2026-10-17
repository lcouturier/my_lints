---
name: dart-quick-fix-authoring
description: "Créer, modifier, relire ou déboguer un quick-fix Dart dans ce dépôt : ResolvedCorrectionProducer, ChangeBuilder, FixKind, correctif local ou fichier entier, enregistrement et tests de transformation."
argument-hint: "[règle ou transformation à corriger]"
---

# Concevoir un quick-fix Dart

## Quand utiliser ce skill

- Ajouter un correctif à une règle existante.
- Modifier un producteur dans `lib/src/fixes/`.
- Corriger un remplacement qui altère la sémantique du code.
- Ajouter une variante applicable à tout le fichier.
- Vérifier l'enregistrement ou la disponibilité d'une action de correction.

Utilise aussi [dart-lint-authoring](../dart-lint-authoring/SKILL.md) lorsque la
règle ou son diagnostic change.

## Établir le contrat

Avant toute modification, note explicitement :

1. le nœud signalé par la règle et le nœud que le correctif doit remplacer ;
2. les préconditions qui rendent la transformation valide ;
3. le code source attendu après transformation ;
4. les cas où aucun correctif ne doit être proposé ;
5. si la transformation est locale ou applicable sans ambiguïté à tout le
   fichier.

Un quick-fix doit préserver le comportement. Ne déduis pas sa validité du seul
fait que le code produit compile.

## Suivre l'implémentation existante

1. Lis la règle, le producteur voisin et son enregistrement dans `lib/main.dart`.
2. Vérifie les versions réellement résolues dans `pubspec.lock`. Ne développe
   pas contre une version jetable d'Analyzer.
3. Étends `ResolvedCorrectionProducer` et conserve le constructeur
   `({required super.context})` utilisé par le dépôt.
4. Déclare un `FixKind` stable et spécifique au package :
   `my_lints.fix.<nomDuFix>`.
5. Choisis `CorrectionApplicability.singleLocation` pour une correction locale
   et `CorrectionApplicability.acrossSingleFile` uniquement si toutes les
   occurrences peuvent être transformées indépendamment.
6. Dans `compute`, vérifie le type et la forme du nœud avant de construire une
   modification. Retourne sans changement lorsque les préconditions échouent.
7. Utilise les API structurées de `ChangeBuilder`, `range.node` et les nœuds AST
   plutôt que des offsets ou recherches textuelles calculés à la main.
8. Enregistre chaque producteur avec le `LintCode` exact de la règle via
   `registerFixForRule` dans `lib/main.dart`.

## Préserver la sémantique

Vérifie au minimum les risques suivants lorsqu'ils concernent la
transformation :

- priorité des opérateurs et parenthèses ;
- opérateur inversé lors d'un échange d'opérandes (`<` devient `>`, `<=`
  devient `>=`) ;
- ordre d'évaluation et effets de bord ;
- opérateurs null-aware et cascades ;
- commentaires, espaces et ponctuation adjacente ;
- différence entre `toString()` et `toSource()` ;
- nœuds imbriqués dont les plages de remplacement se chevauchent ;
- types génériques, promotions et résolution statique.

Si la validité dépend d'un élément ou d'un type résolu, ne base pas la décision
sur le texte du nœud.

## Correctif dans tout le fichier

Pour une variante `InFile` :

1. collecte uniquement les occurrences qui satisfont exactement les mêmes
   préconditions que le correctif local ;
2. emploie un visiteur qui traite chaque type de nœud collecté ;
3. évite les doublons et les remplacements imbriqués ;
4. calcule chaque remplacement depuis l'occurrence correspondante ;
5. retourne immédiatement lorsque la collection est vide ;
6. vérifie qu'une fonction ou déclaration imbriquée n'est pas traitée deux
   fois par des visiteurs différents.

Ne crée pas de variante fichier entier lorsqu'une occurrence peut modifier le
sens ou la plage d'une autre occurrence.

## Tester le code produit

Le harness actuel de `test/rule_test_harness.dart` vérifie les diagnostics mais
ne fournit pas encore d'API générique pour exécuter les
`CorrectionProducer`. Lorsqu'un fix est ajouté ou modifié :

1. conserve les tests de détection de la règle ;
2. ajoute un test ciblé qui exécute réellement le producteur ou enrichis le
   harness avec le plus petit support réutilisable nécessaire ;
3. compare le source complet obtenu au source attendu ;
4. couvre un cas positif, un refus de correction et chaque variante syntaxique
   transformée ;
5. pour un fix `InFile`, couvre plusieurs occurrences et un cas de plages
   potentiellement imbriquées ;
6. résous le source lorsque le producteur dépend des types ou éléments.

Ne remplace pas un test de transformation par un test isolé de la chaîne de
remplacement : il faut valider les plages éditées et le résultat final.

## Validation

1. Formate les fichiers Dart modifiés.
2. Lance d'abord le test de la règle et le test du correctif.
3. Lance `flutter analyze` puis `flutter test` si le harness, un helper partagé
   ou l'enregistrement du plugin a changé.
4. Inspecte le diff pour détecter les changements de texte ou de portée non
   prévus.
5. Signale séparément les diagnostics attendus des exemples et les régressions
   liées au correctif.

## Checklist finale

- Le correctif est-il proposé uniquement quand la transformation est valide ?
- Le `FixKind`, l'applicabilité et le message correspondent-ils à sa portée ?
- Le producteur est-il enregistré pour le bon diagnostic ?
- Le correctif local et le correctif fichier entier ont-ils les mêmes critères ?
- Les opérateurs, parenthèses, null-aware et effets de bord sont-ils préservés ?
- Un test vérifie-t-il le source réellement produit ?