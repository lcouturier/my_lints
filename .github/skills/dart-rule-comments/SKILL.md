---
name: dart-rule-comments
description: Rédiger ou compléter les doc comments des règles d’analyse Dart du dépôt avec une description fidèle à leur comportement et des exemples Bad/Good.
---

# Commentaires des règles Dart

Utilise ce guide lorsque tu ajoutes, complètes ou révises la documentation d'une
classe de règle Dart, en particulier dans `lib/src/rules/`.

## Format attendu

Documente la classe publique de la règle avec un commentaire Dart `///`. Le
commentaire précède les annotations éventuelles, comme `@Deprecated`, afin de
rester attaché à la déclaration.

Garde le commentaire en anglais, conformément aux commentaires existants des
règles. Commence par une phrase résumant l'intention, puis explique brièvement
ce que la règle repère et pourquoi la forme proposée est préférable. Ajoute un
exemple minimal qui montre une forme signalée et sa correction.

```dart
/// A rule that [states the behavior it enforces].
///
/// This rule [explains what it detects and why the preferred form is clearer
/// or safer].
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// [a concise example that triggers this rule]
/// ```
///
/// ✅ Good:
/// ```dart
/// [the corresponding corrected example]
/// ```
class ExampleRule extends AnalysisRule {}
```

## Décrire le comportement réel

Avant d'écrire le commentaire, lis la règle et identifie les nœuds AST enregistrés,
les conditions du visiteur et les éventuelles exclusions. Décris précisément la
portée effective de l'implémentation, pas seulement l'intention suggérée par le
nom ou le message du diagnostic.

- N'affirme pas qu'une règle couvre tous les cas si son visiteur ne reconnaît
  qu'une forme syntaxique particulière.
- Mentionne les limites importantes lorsqu'elles changent le sens du diagnostic,
  par exemple une règle qui ne vérifie que certains appels ou certaines classes.
- Pour une règle dépréciée ou inutilisée, documente son comportement actuel sans
  la présenter comme recommandée ou active.
- N'ajoute pas un commentaire redondant si la classe a déjà un doc comment utile.

## Écrire des exemples utiles

Les exemples doivent isoler le comportement documenté et correspondre aux
conditions réellement reconnues par la règle.

- Utilise des noms simples et du code Dart lisible.
- Fais en sorte que le bloc `Bad` déclenche effectivement le diagnostic.
- Fais en sorte que le bloc `Good` applique la correction décrite sans changer
  l'intention du code.
- Garde les exemples assez courts pour être compris sans contexte extérieur.
- Ajoute le contexte requis par la règle lorsque c'est nécessaire, par exemple
  une classe Flutter pour une règle limitée aux widgets.
- N'invente pas d'API ni de syntaxe Dart. Vérifie les exemples contre la version
  de Dart et les dépendances du dépôt si leur validité est incertaine.

## Vérification avant de terminer

1. Le doc comment précède-t-il la classe et ses annotations ?
2. La première phrase résume-t-elle clairement le rôle de la règle ?
3. L'explication correspond-elle aux conditions observées dans son visiteur ?
4. L'exemple `Bad` déclenche-t-il le diagnostic et l'exemple `Good` l'évite-il ?
5. Les exemples conservent-ils la même intention et utilisent-ils du Dart valide ?
6. Le commentaire existant a-t-il été conservé lorsqu'il était déjà pertinent ?
