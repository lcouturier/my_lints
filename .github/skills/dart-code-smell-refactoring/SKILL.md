---
name: dart-code-smell-refactoring
description: "Repérer, évaluer et refactorer les code smells en Dart ou Flutter. Utiliser pour une revue de maintenabilité, la simplification de code complexe ou dupliqué, la réduction du couplage, ou un refactoring ciblé avec validation comportementale."
---

# Identifier et refactorer les code smells Dart

## Objectif

Trouver les problèmes de conception ou de maintenabilité qui ont un impact concret, les vérifier avec des indices locaux, puis proposer ou appliquer le plus petit refactoring qui améliore le code sans modifier son comportement involontairement.

Un motif inhabituel n'est pas automatiquement un code smell. Ne refactore pas uniquement pour appliquer une préférence stylistique ou réduire le nombre de lignes.

## Quand utiliser ce skill

- Revoir un fichier, un module ou un dépôt à la recherche de problèmes de maintenabilité.
- Évaluer une fonction complexe, du code dupliqué, des responsabilités mêlées ou un couplage difficile à tester.
- Refactorer du code Dart ou Flutter en conservant ses contrats et son comportement.
- Transformer un constat de revue en amélioration ciblée et vérifiée.

Pour les problèmes principalement liés à la complexité algorithmique ou aux performances, appliquer aussi le workflow spécialisé [dart-big-o-refactor](../dart-big-o-refactor/SKILL.md).

## Procédure

1. **Définir le périmètre et l'intention.** Repérer les fichiers, symboles, changements locaux ou symptômes indiqués. Lire les instructions du dépôt, les tests voisins et les appels concernés. Préserver les changements existants. Si la demande porte sur une revue seulement, ne pas modifier le code.

2. **Établir une hypothèse locale vérifiable.** Pour chaque candidat, décrire le coût concret potentiel : risque de régression, difficulté de modification, duplication susceptible de diverger, coût de calcul, gestion d'erreur fragile ou couverture insuffisante. Identifier le chemin de code qui détermine ce comportement et le contrôle le moins coûteux qui pourrait invalider l'hypothèse.

3. **Chercher des indices, pas des verdicts automatiques.** Examiner notamment :
   - fonctions ou classes aux responsabilités nombreuses, avec branches ou états difficiles à suivre ;
   - duplication dont les variantes peuvent évoluer indépendamment ;
   - conditions répétées, niveaux d'imbrication élevés ou mutations éloignées de leur usage ;
   - abstractions, paramètres ou couches qui cachent le comportement au lieu de le clarifier ;
   - erreurs, ressources, flux asynchrones et état Flutter dont le cycle de vie est incomplet ;
   - accès aux données ou parcours de collections dont le coût croît de façon inattendue.

   Vérifier les contre-indices : petit périmètre, abstraction déjà partagée, contraintes d'API, différence sémantique intentionnelle, ou tests démontrant que le code est suffisamment clair et fiable.

4. **Prioriser les constats.** Séparer les défauts observés des risques hypothétiques et des préférences. Donner priorité aux problèmes reproductibles ou ayant un impact plausible élevé. Pour une revue, présenter d'abord les constats actionnables, classés par gravité, avec chemin de fichier, comportement concerné et test manquant éventuel. Ne pas présenter une heuristique de style comme un bug.

5. **Choisir le refactoring minimal.** Préserver les API publiques et les conventions locales sauf nécessité démontrée. Éviter les abstractions nouvelles, les réécritures larges et le nettoyage sans rapport. Pour un risque de performance, comparer la complexité et, si nécessaire, mesurer plutôt que supposer. Pour une règle d'analyse Dart, suivre aussi le skill [`dart-lint-authoring`](../dart-lint-authoring/SKILL.md) ; pour un quick-fix, suivre [`dart-quick-fix-authoring`](../dart-quick-fix-authoring/SKILL.md).

6. **Valider d'abord le point visé.** Après le premier changement, exécuter immédiatement le test ou contrôle le plus ciblé capable de falsifier l'hypothèse : test de comportement, test de transformation, analyse locale ou benchmark pertinent. Si le résultat invalide l'hypothèse, réévaluer le chemin concerné avant d'élargir le changement. En cas d'échec local, corriger le même périmètre et relancer le même contrôle.

7. **Élargir les vérifications selon le risque.** Pour le Dart, utiliser la version de SDK et les dépendances réellement résolues dans le dépôt. Exécuter ensuite les tests ciblés, puis les vérifications globales requises par le projet lorsque le changement touche un contrat partagé. Pour une règle lint, vérifier également l'enregistrement du plugin, la couverture des nœuds AST, les tests résolus ou syntaxiques adaptés et les exemples/documentation concernés. Ne pas confondre les diagnostics intentionnels des exemples de lint avec des erreurs accidentelles ; vérifier les imports, ignores et erreurs Dart sans rapport.

8. **Conclure avec des éléments vérifiables.** Résumer les changements et leur bénéfice concret, citer les fichiers concernés, indiquer exactement les tests et analyses exécutés et signaler les contrôles non exécutés ou interrompus. Ne pas déclarer le refactoring validé si les vérifications déterminantes n'ont pas abouti.

## Critères de qualité

- Le problème identifié est relié à un comportement, un risque ou un coût concret.
- Le refactoring est plus lisible ou plus facile à modifier sans ajouter de complexité nette.
- Les contrats et comportements préexistants sont préservés, sauf changement demandé explicitement.
- Le test ciblé couvre le scénario qui justifie le changement.
- Le périmètre reste limité et les vérifications rapportées correspondent réellement à leurs résultats.
