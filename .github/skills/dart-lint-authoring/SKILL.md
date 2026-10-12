---
name: dart-lint-authoring
description: "Créer ou modifier une règle lint Dart/Flutter dans ce dépôt : AnalysisRule, visiteurs AST, diagnostics, tests, enregistrement du plugin, README et exemple."
argument-hint: "[comportement ou nom de règle]"
---

# Écrire une règle lint

## Quand utiliser

- Ajouter une règle d'analyse Dart ou Flutter à `my_lints`.
- Modifier la détection, le diagnostic ou les cas limites d'une règle existante.
- Ajouter les tests et enregistrer une règle dans le plugin.

## Procédure

1. **Suivre les conventions actuelles.** Lire `pubspec.yaml` et `pubspec.lock`
   pour respecter le SDK et les versions résolues. Examiner une règle voisine
   du même domaine, son test, `test/rule_test_harness.dart`, `lib/main.dart` et
   le catalogue de règles dans `README.md`. Ne pas supposer que l'API ou l'AST
   correspond à une autre version d'Analyzer.
2. **Définir le comportement avant l'implémentation.** Décrire le motif signalé,
   les exclusions et les cas limites sous forme de quelques exemples positifs
   et négatifs. Vérifier qu'une règle existante ne couvre pas déjà le besoin.
   Préférer une détection étroite et testable aux heuristiques générales.
3. **Créer la règle dans le bon domaine.** Placer le fichier dans
   `lib/src/rules/<domaine>/<nom>_rule.dart`. Suivre le modèle du dépôt : classe
   `AnalysisRule`, `LintCode` statique, constructeur qui transmet `code.name` et
   `code.problemMessage` à `super`, getter `diagnosticCode`, puis
   `registerNodeProcessors` et visiteur privé. Garder le nom du diagnostic
   stable, en `snake_case`, et fournir un `correctionMessage` seulement s'il
   indique une correction réellement valable.
4. **Faire correspondre registre et visitor.** Pour chaque appel
   `registry.add<Type>(...)`, implémenter l'override correspondant
   `visit<Type>`. Si un visiteur doit parcourir les descendants, utiliser
   `RecursiveAstVisitor`; pour un traitement local, suivre les usages de
   `SimpleAstVisitor`. Éviter de dépendre directement de `node.parent` pour
   retrouver une déclaration englobante : préférer les helpers existants comme
   `thisOrAncestorMatching` et les extensions du dépôt.
5. **Choisir des tests compatibles avec le motif AST.** Ajouter
   `test/rules/<domaine>/<nom>_rule_test.dart`, réutiliser
   `test/rule_test_harness.dart` et couvrir :
   - le nom, le message et le message de correction du diagnostic ;
   - au moins un cas signalé et les principaux cas non signalés ;
   - les limites importantes (types, opérateurs, portée, imbrication ou
     méthodes exclues).

   Utiliser `runAnalysisRule` pour un motif purement syntaxique. Utiliser
   `resolveSource` puis `runAnalysisRuleOnUnit` lorsque la règle dépend des
   types ou des éléments résolus. Dans ce dépôt, `parseString` et l'AST résolu
   peuvent produire des nœuds différents ; par exemple, ne pas tester avec
   `parseString` une règle qui cible une `InstanceCreationExpression` résolue.
6. **Tester la couverture des nœuds enregistrés.** Lorsque la règle enregistre
   plusieurs types de nœuds ou que la couverture n'est pas évidente, vérifier
   `registeredNodeTypes(rule)` et ajouter un test dédié. Le dispatcher du
   harness doit lui aussi connaître les nœuds traversés. Cette vérification
   évite qu'un processeur soit enregistré sans que son `visit<Type>` soit
   effectivement appelé.
7. **Enregistrer la règle dans le plugin.** Ajouter l'import et
   `registerWarningRule(NomDeLaRegle())` dans `lib/main.dart`, en respectant le
   regroupement existant. Une classe et des tests seuls ne rendent pas la règle
   disponible aux projets qui utilisent le plugin.
8. **Mettre à jour les surfaces publiques utiles.** Ajouter un extrait
   représentatif dans `example/lib/` lorsque cela suit les exemples voisins,
   puis mettre à jour la table des règles de `README.md` avec l'identifiant
   exact de `LintCode`.
9. **Valider la modification.** Formater les fichiers Dart touchés, exécuter le
   test ciblé puis les contrôles du dépôt, au minimum :

   ```sh
   dart format <fichiers Dart modifiés>
   flutter test test/rules/<domaine>/<nom>_rule_test.dart
   flutter analyze
   ```

   Examiner le diff et vérifier que les exemples `Bad` déclenchent la règle,
   que les exemples `Good` ne la déclenchent pas, et que les fichiers
   d'enregistrement et de documentation sont cohérents.

## Correctif rapide

Si la règle doit proposer une correction, traiter le fix comme un changement
distinct : suivre un producteur existant dans `lib/src/fixes/`, l'enregistrer
avec `registerFixForRule` dans `lib/main.dart`, puis tester à la fois la
disponibilité et la sémantique du code produit. Pour une réorganisation
d'opérandes, vérifier notamment que les opérateurs de comparaison sont inversés
quand cela est nécessaire.

## Commentaire de règle

Pour le doc comment public, suivre le format Bad/Good et les critères de
fidélité comportementale du skill
[dart-rule-comments](../dart-rule-comments/SKILL.md). Le commentaire doit
décrire ce que le visiteur détecte réellement, pas une intention plus large.

## Vérification finale

- La règle est-elle enregistrée sur les nœuds AST qu'elle sait traiter ?
- Chaque `add<Type>` a-t-il un `visit<Type>` correspondant et couvert par le
  harness ?
- Les tests résolvent-ils les sources lorsque les types sont nécessaires ?
- Le diagnostic, les exemples, le README et le changelog décrivent-ils le même
  comportement ?
- La règle est-elle effectivement enregistrée dans `lib/main.dart` ?