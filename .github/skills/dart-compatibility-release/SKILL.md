---
name: dart-compatibility-release
description: "Préparer ou relire une montée de version Dart, Flutter ou Analyzer, vérifier la compatibilité du plugin et préparer une publication pub.dev : contraintes SDK, API Analyzer, CI, versionnement, changelog et dry-run."
argument-hint: "[version cible ou publication à préparer]"
---

# Compatibilité et publication du plugin Dart

## Quand utiliser

- Mettre à jour la version minimale ou la plage prise en charge du SDK Dart.
- Mettre à jour `analyzer`, `analyzer_plugin` ou
  `analysis_server_plugin`, ou adapter le plugin à une nouvelle API Analyzer.
- Vérifier la compatibilité avant une publication ou une version de Flutter.
- Préparer ou relire une version pub.dev, son changelog et sa validation.

Ce skill prépare et valide une publication ; il ne publie pas sur pub.dev et ne
crée pas de tag ou de release distante sans demande explicite.

## Établir le contrat de compatibilité

1. Lire `pubspec.yaml`, les versions effectivement résolues dans
   `pubspec.lock`, `.github/workflows/` et les notes de version concernées.
   Distinguer une contrainte déclarée d'une version installée ou testée.
2. Déterminer le changement demandé : version minimale de Dart, borne
   supérieure, version d'Analyzer, API du plugin, ou dépendance Flutter.
   Ne pas relever la version minimale simplement parce qu'une version plus
   récente est disponible.
3. Vérifier la syntaxe des contraintes pub et leur effet exact. Pour chaque
   dépendance directe, confirmer que la contrainte permet la version visée et
   reste compatible avec les autres contraintes du package.
4. Identifier les versions réellement couvertes par la CI. Ne pas annoncer
   comme prises en charge des versions qui ne sont ni déclarées ni vérifiées.
   Si la matrice ne couvre qu'une version stable, signaler cette limite.
5. Pour une évolution Analyzer, lire les API et notes de migration de la version
   cible, rechercher les usages affectés dans `lib/`, `test/` et les exemples,
   puis adapter les règles, visiteurs, diagnostics, correctifs et tests
   concernés. Garder les références à des interfaces publiques et éviter de
   conclure à partir d'une version temporaire ou d'`analyzer: any`.

## Effectuer la mise à jour

1. Modifier uniquement les contraintes et dépendances nécessaires dans
   `pubspec.yaml`. Ne pas éditer manuellement `pubspec.lock` pour simuler une
   résolution : utiliser le gestionnaire de paquets après la modification du
   manifeste.
2. Adapter les usages d'API et leurs tests en suivant les skills
   [dart-lint-authoring](../dart-lint-authoring/SKILL.md),
   [dart-analyzer-ast-debugging](../dart-analyzer-ast-debugging/SKILL.md) et
   [dart-quick-fix-authoring](../dart-quick-fix-authoring/SKILL.md) selon le
   périmètre.
3. Conserver les contraintes antérieures si elles restent supportées.
   Lorsqu'une ancienne version doit être abandonnée, rendre explicite la
   nouvelle version minimale et mettre à jour les vérifications CI.
4. Vérifier les surfaces publiques touchées : exemples, README, configuration
   du plugin et éventuelles consignes de contribution. Éviter les changements
   sans rapport avec la migration.

## Préparer une publication

1. Vérifier que la version de `pubspec.yaml` est la prochaine version voulue et
   qu'elle respecte le versionnement sémantique :
   - correctif pour une correction compatible ;
   - mineure pour une fonctionnalité compatible ;
   - majeure pour une rupture de compatibilité publique.
2. Mettre à jour `CHANGELOG.md` avec les changements livrés, regroupés selon les
   rubriques déjà utilisées dans le dépôt. Ne pas inclure de travail non livré
   ni présenter un changement cassant comme compatible.
3. Vérifier que le README décrit les règles et l'installation actuelles, que
   les fichiers nécessaires sont inclus dans le package et qu'aucun fichier
   local, secret ou artefact de build n'est publié.
4. Exécuter les contrôles du dépôt, puis `dart pub publish --dry-run` pour
   vérifier le contenu et les métadonnées du package. Si l'outil propose des
   corrections, les examiner avant de les appliquer.
5. Présenter les résultats et les éventuels avertissements. La publication
   effective, la création d'un tag et la création d'une GitHub Release sont des
   actions distinctes qui nécessitent une demande explicite.

## Vérifications

Utiliser d'abord les commandes documentées par le dépôt et la version de SDK
visée. Pour ce package, commencer par :

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib
dart analyze --fatal-infos lib
flutter test
```

Puis, si une publication est préparée :

```sh
dart pub publish --dry-run
```

Si une commande échoue à cause de contraintes incompatibles, examiner la
résolution des dépendances et signaler précisément le blocage plutôt que
d'élargir les contraintes sans justification. Après une migration d'API,
exécuter aussi les tests ciblés des règles ou correctifs modifiés avant la
suite complète.

## Compte rendu attendu

- Versions déclarées et résolues pertinentes, et versions effectivement
  testées.
- Modifications de compatibilité et raisons des changements de contraintes.
- Contrôles exécutés, résultats, avertissements et limites de la matrice CI.
- Pour une préparation de publication : version, changelog et résultat du
  `--dry-run`.
- Toute action externe non effectuée, notamment publication, tag ou release.
