library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:my_lints/src/fixes/avoid_enum_values_by_index_fix.dart';
import 'package:my_lints/src/fixes/avoid_i18n_current_fix.dart';
import 'package:my_lints/src/fixes/avoid_yoda_condition_fix.dart';
import 'package:my_lints/src/fixes/avoid_redundant_map_from_fix.dart';
import 'package:my_lints/src/fixes/prefer_any_or_every_fix.dart';
import 'package:my_lints/src/fixes/prefer_contains_fix.dart';
import 'package:my_lints/src/fixes/prefer_explicit_function_type_fix.dart';
import 'package:my_lints/src/fixes/prefer_first_fix.dart';
import 'package:my_lints/src/fixes/prefer_last_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_assignment_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_elements_fix.dart';
import 'package:my_lints/src/fixes/prefer_const_empty_list_after_if_null_fix.dart';
import 'package:my_lints/src/fixes/prefer_null_aware_notation_fix.dart';
import 'package:my_lints/src/fixes/prefer_ternary_over_if_else_fix.dart';
import 'package:my_lints/src/fixes/prefer_void_callback_fix.dart';
import 'package:my_lints/src/fixes/prefer_where_type_fix.dart';
import 'package:my_lints/src/fixes/unprotected_emit_after_await_fix.dart';
import 'package:my_lints/src/rules/bloc/add_cubit_suffix_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_safe_first_where_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_spread_for_addall_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_assignation_in_condition_rule.dart';
import 'package:my_lints/src/rules/style/avoid_cascade_after_if_null_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_compare_same_value_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_disposable_state_field_leaks_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_empty_set_state_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_enum_values_by_index_rule.dart';
import 'package:my_lints/src/rules/strings/avoid_I18n_current_rule.dart';
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
import 'package:my_lints/src/rules/classes/prefer_factory_constructor_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_assignment_rule.dart';
import 'package:my_lints/src/rules/async/prefer_return_await_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_where_type_rule.dart';
import 'package:my_lints/src/rules/classes/proper_super_calls_rule.dart';
import 'package:my_lints/src/rules/record/avoid_extensions_on_records_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_identical_if_branch_rule.dart';
import 'package:my_lints/src/rules/classes/avoid_incomplete_copy_with_rule.dart';
import 'package:my_lints/src/rules/classes/equatable_props_must_include_all_fields_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_nested_ternary_rule.dart';
import 'package:my_lints/src/rules/style/avoid_redundant_duration_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_redundant_collection_rule.dart';
import 'package:my_lints/src/rules/spread/avoid_redundant_spread_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_yoda_condition_rule.dart';
import 'package:my_lints/src/rules/collections/avoid_map_keys_contains_rule.dart';
import 'package:my_lints/src/rules/flutter/avoid_mounted_in_setstate.dart';
import 'package:my_lints/src/rules/style/avoid_nested_assignment_rule.dart';
import 'package:my_lints/src/rules/record/avoid_nested_record_rule.dart';
import 'package:my_lints/src/rules/conditions/avoid_nested_switch_expression_rule.dart';
import 'package:my_lints/src/rules/record/avoid_positional_record_field_access_rule.dart';
import 'package:my_lints/src/rules/classes/avoid_shadowed_extension_methods_rule.dart';
import 'package:my_lints/src/rules/style/avoid_throw_literal_rule.dart';
import 'package:my_lints/src/rules/async/avoid_useless_async_method_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_any_or_every_rule.dart';
import 'package:my_lints/src/rules/spread/prefer_collection_if_for_conditional_elements_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_contains_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_const_empty_list_after_if_null_rule.dart';
import 'package:my_lints/src/rules/types/prefer_explicit_function_type_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_first_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_last_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_elements_rule.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_notation_rule.dart';
import 'package:my_lints/src/rules/spread/prefer_null_aware_spread_rule.dart';
import 'package:my_lints/src/rules/types/prefer_void_callback_rule.dart';
import 'package:my_lints/src/rules/strings/unnecessary_to_string_in_interpolation_rule.dart';
import 'package:my_lints/src/rules/flutter/use_itemextent_for_large_list_rule.dart';
import 'package:my_lints/src/rules/conditions/prefer_ternary_over_if_else_rule.dart';

final plugin = MyLintsPlugin();

class MyLintsPlugin extends Plugin {
  @override
  String get name => 'My Lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(PreferSafeFirstWhereRule())
      ..registerWarningRule(PreferSpreadForAddallRule())
      ..registerWarningRule(AvoidUsageOfNullableListRule())
      ..registerWarningRule(UseItemextentForLargeListRule())
      ..registerWarningRule(AddCubitSuffixRule())
      ..registerWarningRule(AvoidUselessAsyncMethodRule())
      ..registerWarningRule(PreferMapOverMapIndexedRule())
      ..registerWarningRule(AvoidUnnecessaryBlockRule())
      ..registerWarningRule(AvoidUnusedAfterNullCheckRule())
      ..registerWarningRule(CubitStateMustBeEquatableRule())
      ..registerWarningRule(EquatablePropsMustIncludeAllFieldsRule())
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
      ..registerWarningRule(UnnecessaryToStringInInterpolationRule())
      ..registerWarningRule(AvoidToListBeforeJoinRule())
      ..registerWarningRule(AvoidUnawaitedFuturesInCallbacksRule())
      ..registerWarningRule(PreferWhereTypeRule())
      ..registerWarningRule(AvoidI18nCurrentRule())
      ..registerWarningRule(PreferFirstRule())
      ..registerWarningRule(PreferLastRule());

    registry
      ..registerFixForRule(PreferVoidCallbackRule.code, PreferVoidCallbackFix.new)
      ..registerFixForRule(PreferVoidCallbackRule.code, PreferVoidCallbackFixInFile.new)
      ..registerFixForRule(UnProtectedEmitAfterAwaitRule.code, UnProtectedEmitAfterAwaitInsertFix.new)
      ..registerFixForRule(UnProtectedEmitAfterAwaitRule.code, UnProtectedEmitAfterAwaitReplaceFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFix.new)
      ..registerFixForRule(PreferNullAwareAssignmentRule.code, PreferNullAwareAssignmentFixInFile.new)
      ..registerFixForRule(PreferAnyRule.code, PreferAnyOrEveryFix.new)
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
