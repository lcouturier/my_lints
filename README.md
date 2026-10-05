# my_lints

`my_lints` est un plugin du serveur d’analyse Dart qui ajoute des règles de
qualité de code pour Dart et Flutter. Il cible le SDK Dart `3.11.5` ou une
version compatible avec la contrainte `^3.11.5` du package.

## Installation et configuration

Pour utiliser le plugin depuis une copie locale du dépôt, ajoutez-le à votre
fichier `analysis_options.yaml`. Le chemin est relatif à ce fichier :

```yaml
plugins:
  my_lints:
    path: ../my_lints

my_lints:
  rules:
    - prefer_contains_over_indexOf
    - prefer_is_empty
    - use_itemextent_for_large_list
```

Adaptez le chemin au répertoire où se trouve le package. Les noms de règles à
configurer sont les identifiants indiqués dans le catalogue ci-dessous.

## Règles disponibles

Le catalogue ci-dessous recense les règles actuellement enregistrées par le
plugin. Les identifiants sont ceux utilisés dans `analysis_options.yaml`.

### Dart : clarté et contrôle du flux

| Identifiant | Documentation |
| --- | --- |
| `add_cubit_suffix_rule` | Signale les classes Cubit dont le nom ne suit pas la convention de suffixe `Cubit`. |
| `avoid_unnecessary_block` | Évite les blocs `{}` qui n’apportent pas de portée ni de contrôle supplémentaire. |
| `avoid_unused_after_null_check` | Signale les vérifications de nullité après lesquelles le code ne se sert pas du résultat de cette vérification. |
| `avoid_incomplete_copy_with` | Détecte les méthodes `copyWith` qui ne recopient pas les propriétés de l’objet comme attendu. |
| `proper_super_calls` | Vérifie les appels à `super` attendus dans les méthodes redéfinies concernées. |
| `avoid_assignation_in_condition` | Évite les affectations intégrées à une condition, difficiles à distinguer d’une comparaison. |
| `avoid_nested_assignment` | Évite les affectations imbriquées dans une autre expression. |
| `avoid_identical_if_branch` | Signale les branches `if` qui exécutent le même code. |
| `avoid_compare_same_value` | Signale les comparaisons dont les deux opérandes sont la même valeur. |
| `avoid_yoda_conditions` | Préfère placer la valeur ou constante à droite de l’opérateur de comparaison. |
| `avoid_double_negation_conditions` | Évite les conditions rendues difficiles à lire par une double négation. |
| `avoid_negative_boolean` | Évite les noms booléens négatifs qui rendent les conditions et leur négation confuses. |
| `avoid_nested_switch_expression_rule` | Évite les expressions `switch` imbriquées difficiles à parcourir. |
| `avoid_nested_ternary` | Évite les opérateurs ternaires imbriqués ; préférez une structure de contrôle plus lisible. |
| `avoid_cascade_after_if_null` | Signale l’opérateur cascade appliqué directement après `??`, qui peut nécessiter des parenthèses pour lever l’ambiguïté. |
| `avoid_shadowed_extension_methods` | Signale les méthodes d’extension qui masquent une méthode portant le même nom sur le type étendu. |
| `avoid_throw_literal` | Évite de lever une valeur littérale au lieu d’une exception ou d’une erreur explicite. |
| `prefer_explicit_function_type` | Préfère une signature de fonction explicite au type générique `Function`. |
| `prefer_return_await` | Préserve `await` dans un `return` lorsque cela est nécessaire au comportement attendu, notamment à la gestion des erreurs. |
| `avoid_useless_async_method` | Signale les méthodes `async` qui n’effectuent aucune opération asynchrone utile. |
| `prefer_void_callback` | Préfère le type de retour `void` pour les callbacks qui ne renvoient pas de valeur exploitable. |

### Dart : collections et null safety

| Identifiant | Documentation |
| --- | --- |
| `prefer_null_aware_assignment` | Remplace le test explicite de nullité suivi d’une affectation par `??=` lorsque c’est équivalent. |
| `prefer_null_aware_notation` | Préfère l’accès null-aware (`?.`) aux tests de nullité suivis d’un accès. |
| `prefer_null_aware_elements` | Préfère les éléments null-aware dans les collections lorsque l’ajout dépend de la nullité d’une valeur. |
| `prefer_null_aware_spread` | Préfère la syntaxe de spread null-aware (`...?`) pour développer une collection nullable. |
| `prefer_const_empty_list_after_if_null` | Préfère `const []` comme valeur de repli après `??`. |
| `avoid_redundant_collection` | Signale les conversions ou constructions de collection redondantes. |
| `avoid_redundant_spread` | Signale les opérateurs spread qui n’apportent rien à la collection construite. |
| `avoid_map_keys_contains` | Remplace `map.keys.contains(key)` par `map.containsKey(key)`. |
| `prefer_any` | Préfère les vérifications de collection avec `any` ou `every` aux parcours ou transformations intermédiaires équivalents. |
| `prefer_contains_over_indexOf` | Préfère `contains()` à `indexOf()` comparé à `-1` pour vérifier la présence d’un élément. |
| `prefer_is_empty` | Préfère `isEmpty` ou `isNotEmpty` aux comparaisons de `length` avec zéro. |
| `prefer_try_get_value` | Préfère l’opération de récupération sûre reconnue par la règle aux séquences de vérification et d’accès redondantes sur une map. |
| `prefer_where_type` | Préfère `whereType<T>()` au filtrage manuel par type suivi d’une conversion. |
| `prefer_first_over_index` | Préfère `first` aux accès par index qui désignent le premier élément d’une collection. |
| `prefer_last_over_index` | Préfère `last` aux calculs d’index qui désignent le dernier élément d’une collection. |
| `prefer_map_over_mapIndexed` | Préfère `map` à `mapIndexed` lorsque l’index n’est pas utilisé. |
| `prefer_collection_if_for_conditional_elements` | Préfère les éléments `if`/`for` intégrés aux collections aux constructions conditionnelles intermédiaires. |

### Dart : records, chaînes et durées

| Identifiant | Documentation |
| --- | --- |
| `avoid_mixing_named_and_positional_fields` | Évite de mélanger des champs nommés et positionnels dans un record. |
| `avoid_nested_record` | Évite les records imbriqués, qui rendent les données et leurs accès difficiles à lire. |
| `avoid_positional_record_field_access` | Préfère les champs nommés aux accès positionnels aux champs d’un record. |
| `avoid_extensions_on_records` | Évite de définir des extensions sur des records. |
| `unnecessary_string_interpolation` | Évite l’interpolation superflue d’une chaîne qui peut être écrite directement. |
| `unnecessary_to_string_in_interpolation` | Évite les appels à `toString()` redondants dans une interpolation. |
| `avoid_tolist_before_join` | Évite de matérialiser une liste avec `toList()` avant d’appeler `join()`. |
| `avoid_join_on_nullable_item` | Signale l’utilisation de `join()` lorsque les éléments de l’itérable peuvent être nuls. |
| `avoid_join_on_non_strings` | Signale l’utilisation de `join()` sur un itérable dont les éléments ne sont pas des chaînes. |
| `avoid_redundant_duration` | Évite les constructions ou calculs de `Duration` redondants. |

### Flutter et Bloc

| Identifiant | Documentation |
| --- | --- |
| `cubit_state_must_be_equatable` | Encourage des états de Cubit comparables par valeur, notamment en implémentant `Equatable` lorsque c’est approprié. |
| `unprotected_emit_after_await` | Protège les appels à `emit` effectués après un `await` contre l’émission après la fermeture du Bloc ou du Cubit. |
| `avoid_disposable_state_field_leaks` | Signale les contrôleurs ou ressources détenus par un `State` qui ne sont pas libérés. |
| `avoid_empty_set_state` | Évite les appels à `setState` dont le callback ne modifie aucun état. |
| `avoid_mounted_in_set_state` | Évite de vérifier `mounted` à l’intérieur du callback de `setState` ; effectuez la vérification avant l’appel. |
| `prefer_spacing_over_divide_widgets` | Préfère des widgets d’espacement aux séparateurs employés uniquement pour créer un espace entre des widgets. |
| `do_not_call_to_list_after_divide_widgets` | Évite l’appel superflu à `toList()` après la division de widgets par la méthode concernée. |
| `use_itemextent_for_large_list` | Pour `ListView.builder`, recommande `itemExtent` ou `prototypeItem` afin d’éviter de mesurer chaque élément. |
| `avoid_i18n_current` | Évite l’accès global `I18n.current` lorsque la règle peut utiliser le contexte de localisation. |
| `prefer_correct_callback_field_name` | Signale les noms de champs de callback qui ne respectent pas la convention attendue par la règle. |
| `prefer_factory_constructor` | Préfère un constructeur `factory` lorsque le constructeur doit renvoyer une instance existante ou une instance d’un sous-type. |

## Correctifs rapides

Plusieurs règles proposent un correctif rapide dans l’éditeur, notamment pour
`prefer_is_empty`, `prefer_null_aware_assignment`, `prefer_null_aware_notation`,
`prefer_null_aware_elements`, `prefer_contains_over_indexOf`,
`prefer_first_over_index`, `prefer_last_over_index`, `prefer_where_type`,
`prefer_void_callback` et `unprotected_emit_after_await`. La disponibilité d’un
correctif dépend du diagnostic et du contexte du code.

## Exemples

Le répertoire [`example/lib`](example/lib) contient des extraits de code qui
illustrent plusieurs règles. Il sert également de projet d’exemple pour
configurer le plugin localement.

## Développement

Pour exécuter les tests du package :

```sh
flutter test
```

Les règles sont implémentées dans `lib/src/rules/`, regroupées par thème
(`async`, `bloc`, `classes`, `collections`, `conditions`, `flutter`, `record`,
`spread`, `strings`, `style` et `types`). Les tests suivent la même organisation
dans `test/rules/`. Les règles sont enregistrées dans `lib/main.dart`.
Lorsqu’une règle est ajoutée ou modifiée, mettez à jour ce catalogue et ajoutez
ou adaptez les tests correspondants.
