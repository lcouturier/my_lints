# Instructions pour les agents

## Projet

- Ce dépôt est un plugin du serveur d'analyse Dart qui fournit des règles pour Dart et Flutter.
- Le package cible le SDK Dart `^3.11.5`. Respecte les contraintes de versions déclarées dans `pubspec.yaml` et les API de la version d'`analyzer` réellement résolue.
- Les règles sont dans `lib/src/rules/`, regroupées par domaine. Leur enregistrement se trouve dans `lib/main.dart`.
- Les tests sont dans `test/rules/` et suivent l'organisation des règles. `example/lib/` contient des exemples de code concernés par les diagnostics.

## Modifications

- Avant de modifier une règle, suis son flux existant : nœuds AST enregistrés, visiteur, diagnostic, correctif éventuel et tests associés.
- Vérifie qu'un visiteur traite effectivement chaque type de nœud enregistré et que sa stratégie de parcours ne manque pas de nœuds pertinents.
- Distingue les tests sur AST parsé des tests sur AST résolu. Utilise `parseString` pour les règles syntaxiques ; utilise les helpers de résolution du harness quand le comportement dépend des éléments ou des types.
- Pour les correctifs rapides, vérifie que la transformation préserve la sémantique, notamment l'opérateur et l'ordre des opérandes.
- Garde les changements ciblés et compatibles avec les conventions voisines. N'ajoute pas de couches d'architecture ou de dépendances sans nécessité démontrée.
- Préserve la null safety et les types explicites. Évite `dynamic`, sauf lorsqu'une API ou un double de test existant le requiert.
- Lorsqu'une règle est ajoutée ou modifiée, adapte les tests et, si pertinent, son enregistrement, l'exemple et le catalogue de `README.md`.

## Vérification

- Lance d'abord le test ciblé de la règle modifiée, puis élargis la vérification si le changement affecte des composants partagés.
- La commande documentée pour l'ensemble du package est `flutter test`.
- Indique les vérifications exécutées et les limites restantes. Ne présente pas une erreur préexistante et sans lien comme une régression de ton changement.
