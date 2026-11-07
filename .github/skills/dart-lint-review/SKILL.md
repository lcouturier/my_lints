---
name: dart-lint-review
description: "Relire une règle lint Dart ou Flutter de ce dépôt : évaluer ses diagnostics, cas limites AST, faux positifs ou négatifs, visiteurs, tests, quick-fixes et documentation. Utiliser pour une revue ou un audit de règles existantes."
argument-hint: "[règle, domaine ou périmètre à relire]"
---

# Relire une règle lint Dart

## Quand utiliser

- Relire une règle lint existante ou un ensemble ciblé de règles.
- Rechercher des faux positifs, des faux négatifs ou des cas limites non couverts.
- Vérifier la cohérence entre la règle, ses tests, son enregistrement et sa documentation.
- Examiner une modification de règle avant sa fusion.

Ne pas utiliser ce skill pour créer une règle : suivre
[dart-lint-authoring](../dart-lint-authoring/SKILL.md).

## Procédure

1. **Définir le périmètre.** Lire les instructions du dépôt et les changements
   concernés. Ne pas élargir la revue à des fichiers sans lien.

2. **Tracer le comportement de bout en bout.** Examiner l’implémentation de la
   règle, les nœuds enregistrés, les méthodes `visit...`, le diagnostic,
   l’enregistrement dans `lib/main.dart`, les tests associés et les surfaces
   documentées dans `README.md` et `example/lib/`.

3. **Vérifier la détection.**
   - Comparer les conditions du visiteur au comportement annoncé par la règle.
   - Chercher les cas voisins susceptibles de produire un faux positif ou un
     faux négatif : portée, imbrication, types, opérateurs et variantes syntaxiques.
   - Vérifier que chaque type de nœud enregistré est effectivement traité.
   - Utiliser l’AST résolu lorsque la règle dépend des types ou des éléments ;
     suivre [dart-analyzer-ast-debugging](../dart-analyzer-ast-debugging/SKILL.md)
     si la forme de l’AST est déterminante.

4. **Évaluer les tests.**
   - Vérifier qu’ils couvrent au moins un cas signalé et les cas voisins non signalés.
   - Confirmer que le harness distribue les nœuds visités par la règle.
   - Distinguer les tests syntaxiques des tests nécessitant une résolution.
   - Signaler les lacunes importantes sans exiger une couverture exhaustive
     de toutes les permutations.

5. **Examiner les correctifs rapides, s’il y en a.**
   Vérifier que le correctif est proposé uniquement lorsque ses préconditions
   sont satisfaites et qu’il préserve la sémantique, notamment l’ordre
   d’évaluation, les opérateurs, les parenthèses et les types.

6. **Prioriser les constats.** Présenter d’abord les problèmes concrets et
   reproductibles. Distinguer les défauts observés des risques hypothétiques
   et des préférences de style. Ne pas qualifier une préférence stylistique
   de bug.

7. **Valider uniquement ce qui est nécessaire.** Lancer les tests ciblés ou
   contrôles pertinents pour confirmer un constat. Ne pas modifier le code
   pendant une revue, sauf demande explicite.

## Format du compte rendu

Pour chaque constat, fournir :
- la gravité et le niveau de confiance ;
- le fichier et les lignes concernées ;
- le comportement problématique et son impact ;
- un scénario minimal ou le test manquant, si utile.

Classer les constats par gravité, puis par confiance. Si aucun problème
actionnable n’est trouvé, le dire clairement et mentionner les limites de la
revue et les validations effectuées.
