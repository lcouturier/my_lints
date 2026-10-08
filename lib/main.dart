// ignore_for_file: unused_import

library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:my_lints/src/fixes/avoid_enum_values_by_index_fix.dart';
import 'package:my_lints/src/fixes/avoid_i18n_current_fix.dart';
import 'package:my_lints/src/fixes/avoid_yoda_condition_fix.dart';
import 'package:my_lints/src/fixes/avoid_redundant_map_from_fix.dart';
import 'package:my_lints/src/fixes/prefer_addition_subtraction_assignments_fix.dart';
import 'package:my_lints/src/fixes/prefer_any_or_every_fix.dart';
import 'package:my_lints/src/fixes/prefer_contains_fix.dart';
import 'package:my_lints/src/fixes/prefer_explicit_function_type_fix.dart';
import 'package:my_lints/src/fixes/prefer_first_fix.dart';
import 'package:my_lints/src/fixes/prefer_is_empty_fix.dart';
import 'package:my_lints/src/fixes/prefer_last_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_assignment_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_elements_fix.dart';
import 'package:my_lints/src/fixes/prefer_const_empty_list_after_if_null_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_notation_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_coalescing_operator_fix.dart';
import 'package:my_lints/src/fixes/prefer_ternary_over_if_else_fix.dart';
import 'package:my_lints/src/fixes/prefer_usage_of_value_getter_fix.dart';
import 'package:my_lints/src/fixes/prefer_void_callback_fix.dart';
import 'package:my_lints/src/fixes/prefer_where_type_fix.dart';
import 'package:my_lints/src/fixes/unprotected_emit_after_await_fix.dart';
import 'package:my_lints/src/rules/bloc/add_cubit_suffix_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_safe_first_where_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_assignation_in_condition_rule.dart';
import 'package:my_lints/src/rules/strings/prefer_string_interpolation_rule.dart';
import 'package:my_lints/src/rules/types/avoid_always_null_parameters_rule.dart';
import 'package:my_lints/src/rules/style/avoid_cascade_after_if_null_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_compare_same_value_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_complex_loop_conditions_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_complicated_conditional_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_conditional_expression_in_parameter_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_deep_condition_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_disposable_state_field_leaks_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_high_cyclomatic_complexity_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_long_conditions_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_context_in_init_state_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_double_negation_conditions_rule.dart';
import 'package:my_lints/src/rules/types/avoid_dynamic_type_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_empty_set_state_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_enum_values_by_index_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_for_each_rule.dart';
import 'package:my_lints/src/rules/strings/avoid_I18n_current_rule.dart';
import 'package:my_lints/src/rules/strings/avoid_join_on_nullable_item_rule.dart';
import 'package:my_lints/src/rules/style/avoid_magic_numbers_rule.dart';
import 'package:my_lints/src/rules/strings/avoid_nullable_interpolation_rule.dart';
import 'package:my_lints/src/rules/strings/avoid_tolist_before_join_rule.dart';
import 'package:my_lints/src/rules/async/avoid_unawaited_futures_in_callbacks_rule.dart';
import 'package:my_lints/src/rules/style/avoid_unnecessary_block_rule.dart';
import 'package:my_lints/src/rules/types/avoid_nullable_list_return_type_rule.dart';
import 'package:my_lints/src/rules/types/avoid_unused_after_null_check_rule.dart';
import 'package:my_lints/src/rules/bloc/cubit_state_must_be_equatable_rule.dart';
import 'package:my_lints/src/rules/flutter/do_not_call_to_list_after_divide_widgets_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_map_over_map_indexed_rule.dart';
import 'package:my_lints/src/rules/flutter/prefer_no_spacing_over_divide_widgets_rule.dart';
import 'package:my_lints/src/rules/async/unprotected_emit_after_await_rule.dart';
import 'package:my_lints/src/rules/bloc/prefer_bloc_extensions_rule.dart';
import 'package:my_lints/src/rules/classes/prefer_factory_constructor_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_assignment_rule.dart';
import 'package:my_lints/src/rules/async/prefer_return_await_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_where_type_rule.dart';
import 'package:my_lints/src/rules/classes/proper_super_calls_rule.dart';
import 'package:my_lints/src/rules/record/avoid_extensions_on_records_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_identical_if_branch_rule.dart';
import 'package:my_lints/src/rules/classes/avoid_incomplete_copy_with_rule.dart';
import 'package:my_lints/src/rules/style/avoid_magic_duration_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_negative_boolean_names_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_nested_ternary_rule.dart';
import 'package:my_lints/src/rules/style/avoid_redundant_duration_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_redundant_collection_rule.dart';
import 'package:my_lints/src/rules/spread/avoid_redundant_spread_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_yoda_condition_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_map_keys_contains_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_mounted_in_setstate.dart';
import 'package:my_lints/src/rules/style/avoid_nested_assignment_rule.dart';
import 'package:my_lints/src/rules/record/avoid_nested_record_rule.dart';
import 'package:my_lints/src/rules/types/avoid_mixing_named_and_positional_fields.dart';
import 'package:my_lints/src/rules/conditions/avoid_nested_switch_expression_rule.dart';
import 'package:my_lints/src/rules/record/avoid_positional_record_field_access_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_unsafe_reduce_rule.dart';
import 'package:my_lints/src/rules/bloc/avoid_returning_value_from_cubit_methods_rule.dart';
import 'package:my_lints/src/rules/classes/avoid_shadowed_extension_methods_rule.dart';
import 'package:my_lints/src/rules/style/avoid_throw_literal_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_unnecessary_gesture_detector_rule.dart';
import 'package:my_lints/src/rules/async/avoid_useless_async_method_rule.dart';
import 'package:my_lints/src/rules/flutter/edge_insets_rule.dart';
import 'package:my_lints/src/rules/style/prefer_addition_subtraction_assignments_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_any_or_every_rule.dart';
import 'package:my_lints/src/rules/spread/prefer_collection_if_for_conditional_elements_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_contains_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_const_empty_list_after_if_null_rule.dart';
import 'package:my_lints/src/rules/types/prefer_correct_callback_field_name_rule.dart';
import 'package:my_lints/src/rules/types/prefer_explicit_function_type_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_first_rule.dart';
import 'package:my_lints/src/rules/types/prefer_function_typedefs_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_is_empty_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_last_rule.dart';
import 'package:my_lints/src/rules/types/prefer_named_bool_parameters_rule.dart';
import 'package:my_lints/src/rules/record/prefer_named_record_fields_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_elements_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_notation_rule.dart';
import 'package:my_lints/src/rules/spread/prefer_null_aware_spread_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_try_get_value_rule.dart';
import 'package:my_lints/src/rules/types/prefer_usage_of_value_getter_rule.dart';
import 'package:my_lints/src/rules/types/prefer_void_callback_rule.dart';
import 'package:my_lints/src/rules/strings/unnecessary_string_interpolation_rule.dart';
import 'package:my_lints/src/rules/strings/unnecessary_to_string_in_interpolation_rule.dart';
import 'package:my_lints/src/rules/flutter/use_itemextent_for_large_list_rule.dart';
import 'package:my_lints/src/rules/strings/use_join_on_strings_rule.dart';
import 'package:my_lints/src/rules/conditions/prefer_ternary_over_if_else_rule.dart';
import 'package:my_lints/src/rules/flutter/prefer_keyed_widgets_rule.dart';
import 'package:my_lints/src/rules/spread/prefer_if_elements_to_ternary_spread_rule.dart';

final plugin = MyLintsPlugin();

class MyLintsPlugin extends Plugin {
  @override
  String get name => 'My Lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(PreferSafeFirstWhereRule())
      ..registerWarningRule(AvoidUsageOfNullableListRule())
      ..registerWarningRule(UseItemextentForLargeListRule())
      ..registerWarningRule(AddCubitSuffixRule())
      ..registerWarningRule(AvoidUselessAsyncMethodRule())
      ..registerWarningRule(PreferMapOverMapIndexedRule())
      ..registerWarningRule(AvoidUnnecessaryBlockRule())
      ..registerWarningRule(AvoidUnusedAfterNullCheckRule())
      ..registerWarningRule(CubitStateMustBeEquatableRule()) // pas utile
      ..registerWarningRule(UnProtectedEmitAfterAwaitRule())
      ..registerWarningRule(PreferSpacingOverDivideWidgetsRule())
      ..registerWarningRule(DoNotCallToListAfterDivideWidgetsRule())
      ..registerWarningRule(AvoidIncompleteCopyWithRule())
      ..registerWarningRule(ProperSuperCallsRule())
      ..registerWarningRule(PreferFactoryConstructorRule())
      ..registerWarningRule(PreferNullAwareAssignmentRule())
      ..registerWarningRule(PreferExplicitFunctionType())
      ..registerWarningRule(PreferAnyRule())
      ..registerWarningRule(PreferNullAwareSpreadRule())
      ..registerWarningRule(AvoidNestedSwitchExpressionRule())
      ..registerWarningRule(AvoidNestedRecordRule())
      ..registerWarningRule(AvoidYodaConditionsRule())
      ..registerWarningRule(PreferContainsRule())
      ..registerWarningRule(PreferCollectionIfForConditionalElementsRule())
      ..registerWarningRule(PreferIsEmptyRule())
      ..registerWarningRule(AvoidPositionalRecordFieldAccessRule())
      ..registerWarningRule(PreferNullAwareElementsRule())
      ..registerWarningRule(PreferConstEmptyListAfterIfNullRule())
      ..registerWarningRule(AvoidDisposableStateFieldLeaksRule())
      ..registerWarningRule(PreferNullAwareNotationRule())
      ..registerWarningRule(PreferVoidCallbackRule())
      ..registerWarningRule(AvoidNestedAssignmentRule())
      ..registerWarningRule(AvoidMapKeysContainsRule())
      ..registerWarningRule(AvoidShadowedExtensionMethodsRule())
      ..registerWarningRule(AvoidCompareSameValueRule())
      ..registerWarningRule(AvoidRedundantDurationRule())
      ..registerWarningRule(AvoidCascadeAfterIfNullRule())
      ..registerWarningRule(AvoidEmptySetStateRule())
      ..registerWarningRule(AvoidMountedInSetStateRule())
      ..registerWarningRule(AvoidThrowLiteralRule())
      ..registerWarningRule(AvoidNestedTernaryRule())
      ..registerWarningRule(AvoidExtensionsOnRecordsRule())
      ..registerWarningRule(AvoidAssignationInConditionRule())
      ..registerWarningRule(AvoidIdenticalIfBranchRule())
      ..registerWarningRule(AvoidRedundantCollectionRule())
      ..registerWarningRule(AvoidRedundantSpreadRule())
      ..registerWarningRule(PreferReturnAwaitRule())
      ..registerWarningRule(UnnecessaryStringInterpolationRule())
      ..registerWarningRule(UnnecessaryToStringInInterpolationRule())
      ..registerWarningRule(AvoidToListBeforeJoinRule())
      ..registerWarningRule(AvoidUnawaitedFuturesInCallbacksRule())
      ..registerWarningRule(PreferWhereTypeRule())
      ..registerWarningRule(AvoidI18nCurrentRule())
      ..registerWarningRule(PreferFirstRule())
      ..registerWarningRule(PreferLastRule());

    registry
      ..registerFixForRule(PreferIsEmptyRule.code, PreferIsEmptyFix.new)
      ..registerFixForRule(PreferIsEmptyRule.code, PreferIsEmptyFixInFile.new)
      ..registerFixForRule(PreferVoidCallbackRule.code, PreferVoidCallbackFix.new)
      ..registerFixForRule(PreferVoidCallbackRule.code, PreferVoidCallbackFixInFile.new)
      ..registerFixForRule(UnProtectedEmitAfterAwaitRule.code, UnProtectedEmitAfterAwaitInsertFix.new)
      ..registerFixForRule(UnProtectedEmitAfterAwaitRule.code, UnProtectedEmitAfterAwaitReplaceFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFixInFile.new)
      ..registerFixForRule(PreferAnyRule.code, PreferAnyOrEveryFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFixInFile.new)
      ..registerFixForRule(PreferNullAwareElementsRule.code, PreferNullAwareElementsFix.new)
      ..registerFixForRule(PreferNullAwareNotationRule.code, PreferNullAwareNotationFix.new)
      ..registerFixForRule(PreferNullAwareNotationRule.code, PreferNullAwareNotationFixInFile.new)
      ..registerFixForRule(PreferConstEmptyListAfterIfNullRule.code, PreferConstEmptyListAfterIfNullFix.new)
      ..registerFixForRule(PreferConstEmptyListAfterIfNullRule.code, PreferConstEmptyListAfterIfNullFixInFile.new)
      ..registerFixForRule(AvoidYodaConditionsRule.code, AvoidYodaConditionFix.new)
      ..registerFixForRule(AvoidYodaConditionsRule.code, AvoidYodaConditionFixInFile.new)
      ..registerFixForRule(PreferContainsRule.code, PreferContainsFix.new)
      ..registerFixForRule(PreferTernaryOverIfElseRule.code, PreferTernaryOverIfElseFix.new)
      ..registerFixForRule(PreferLastRule.code, PreferLastFix.new)
      ..registerFixForRule(PreferLastRule.code, PreferLastFixInFile.new)
      ..registerFixForRule(AvoidEnumValuesByIndexRule.code, AvoidEnumValuesByIndexFix.new)
      ..registerFixForRule(PreferExplicitFunctionType.code, PreferExplicitFunctionTypeFix.new)
      ..registerFixForRule(AvoidRedundantCollectionRule.code, AvoidRedundantMapFromFix.new)
      ..registerFixForRule(AvoidRedundantCollectionRule.code, AvoidRedundantMapFromFixInFile.new)
      ..registerFixForRule(PreferWhereTypeRule.code, PreferWhereTypeFix.new)
      ..registerFixForRule(PreferWhereTypeRule.code, PreferWhereTypeFixInFile.new)
      ..registerFixForRule(AvoidI18nCurrentRule.code, AvoidI18nCurrentFix.new)
      ..registerFixForRule(AvoidI18nCurrentRule.code, AvoidI18nCurrentFixInFile.new)
      ..registerFixForRule(PreferFirstRule.code, PreferFirstFix.new)
      ..registerFixForRule(PreferFirstRule.code, PreferFirstFixInFile.new);
  }
}
