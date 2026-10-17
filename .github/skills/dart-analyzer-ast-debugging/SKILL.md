---
name: dart-analyzer-ast-debugging
description: "Diagnostiquer un comportement AST ou de résolution dans ce dépôt : Analyzer versionné, AST parsé ou résolu, types de nœuds, chaînes de parents, éléments, types statiques, visiteurs et faux négatifs de règles lint."
argument-hint: "[source minimale ou règle à diagnostiquer]"
---

# Déboguer l'AST Dart Analyzer

## Quand utiliser ce skill

- Une règle ne visite pas le nœud attendu ou produit un faux négatif.
- Le même source donne un AST différent entre un test et le plugin.
- Le comportement dépend de `staticType`, `element`, d'une promotion ou d'une
  déclaration englobante.
- Une montée de version d'Analyzer casse un visiteur ou une extension AST.
- Il faut choisir entre `parseString` et une unité résolue.

Pour modifier ensuite une règle, applique aussi
[dart-lint-authoring](../dart-lint-authoring/SKILL.md).

## Verrouiller l'environnement

1. Lis les contraintes dans `pubspec.yaml` et la version effectivement résolue
   dans `pubspec.lock`.
2. Exécute les sondes dans ce dépôt afin de réutiliser son SDK et son graphe de
   dépendances.
3. N'utilise jamais un projet temporaire avec `analyzer: any` pour conclure sur
   l'AST du dépôt.
4. Réduis le problème à un source minimal qui conserve le comportement observé.

Les noms de classes internes comme `*Impl` sont utiles pour diagnostiquer, mais
le code de production doit cibler les interfaces AST publiques.

## Choisir AST parsé ou résolu

Utilise `parseString` lorsque la règle dépend uniquement de la syntaxe :

- lexèmes et opérateurs ;
- structure des expressions ;
- présence d'un modificateur ou d'un argument ;
- relations parent-enfant purement syntaxiques.

Utilise `resolveSource` et `runAnalysisRuleOnUnit` lorsque la règle dépend de :

- `staticType` ou `element` ;
- constructeurs et invocations distingués par la résolution ;
- héritage, interfaces ou types Flutter ;
- promotions et portée ;
- imports, préfixes ou symboles provenant d'un package.

Une assertion obtenue sur AST parsé ne prouve pas le comportement du plugin si
celui-ci travaille sur une unité résolue.

## Construire une sonde discriminante

Inspecte seulement les données capables de départager les hypothèses locales :

1. `runtimeType` du nœud et de ses enfants pertinents ;
2. `toSource()`, offset et longueur ;
3. chaîne des parents jusqu'à la déclaration englobante ;
4. `staticType`, `element` ou `declaredElement` lorsque disponibles ;
5. méthode de visite appelée ;
6. types enregistrés dans `RuleVisitorRegistry`.

Préfère un test temporaire ou une petite sonde exécutée avec les dépendances du
dépôt. Supprime la sonde après avoir converti l'observation en test de
régression durable.

## Vérifier registre et visiteurs

Pour chaque `registry.add<TypeDeNoeud>` :

1. confirme que le visiteur implémente `visitTypeDeNoeud` ;
2. vérifie que `test/rule_test_harness.dart` distribue ce type si le test passe
   par `_RuleVisitorDispatcher` ;
3. utilise `registeredNodeTypes(rule)` pour figer la couverture attendue ;
4. choisis `SimpleAstVisitor` pour un traitement local et
   `RecursiveAstVisitor` lorsqu'une descente explicite est nécessaire ;
5. appelle `super.visit...` seulement lorsque les descendants doivent encore
   être parcourus ;
6. contrôle les déclarations imbriquées pour éviter doubles diagnostics ou
   héritage accidentel du contexte extérieur.

Ne suppose pas que `node.parent` est directement une classe ou une déclaration.
Analyzer peut intercaler des nœuds de corps ; utilise les helpers d'ancêtres du
dépôt lorsque la relation recherchée n'est pas strictement directe.

## Transformer le diagnostic en test

Ajoute le test le moins large qui reproduit le problème :

- type exact de nœud enregistré ;
- cas positif et cas voisin non signalé ;
- source résolu si des types ou éléments sont consultés ;
- déclaration imbriquée si la portée est en cause ;
- syntaxe alternative lorsque le même code peut produire plusieurs formes AST.

Le test doit échouer avant la correction pour la raison attendue. Après la
correction, relance d'abord ce test, puis les tests de la règle complète.

## Pièges connus dans ce dépôt

- La version réellement résolue d'Analyzer peut différer de la contrainte
  minimale déclarée ; `pubspec.lock` fait foi pour le diagnostic local.
- AST parsé et AST résolu peuvent représenter différemment une construction ou
  une invocation.
- Une déclaration peut avoir un nœud de corps intermédiaire entre elle et ses
  membres ; une vérification du parent direct est fragile.
- Un visiteur récursif lancé sur une méthode peut aussi traverser les fonctions
  locales et produire des diagnostics en double.
- Un type enregistré mais absent du dispatcher de test crée une couverture
  trompeuse.

## Validation

1. Formate les fichiers modifiés.
2. Lance le test minimal qui prouve l'hypothèse.
3. Lance tous les tests de la règle touchée.
4. Élargis à `flutter test` lorsque le harness ou un helper AST partagé change.
5. Exécute `flutter analyze` et distingue les diagnostics intentionnels de
   `example/lib/` des erreurs introduites dans `lib/` ou `test/`.

## Compte rendu attendu

Indique :

- la version d'Analyzer utilisée ;
- AST parsé ou résolu ;
- le type de nœud et la relation de parenté observés ;
- l'hypothèse confirmée ou réfutée ;
- le test ajouté ;
- les validations exécutées et leurs limites.