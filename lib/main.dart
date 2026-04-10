library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:my_lints/src/fixes/avoid_enum_values_by_index_fix.dart';
import 'package:my_lints/src/fixes/avoid_invert_condition_fix.dart';
import 'package:my_lints/src/fixes/prefer_addition_subtraction_assignments_fix.dart';
import 'package:my_lints/src/fixes/prefer_any_or_every_fix.dart';
import 'package:my_lints/src/fixes/prefer_contains_fix.dart';
import 'package:my_lints/src/fixes/prefer_explicit_function_type_fix.dart';
import 'package:my_lints/src/fixes/prefer_first_fix.dart';
import 'package:my_lints/src/fixes/prefer_last_fix.dart';
import 'package:my_lints/src/fixes/prefer_usage_of_value_getter_fix.dart';
import 'package:my_lints/src/rules/avoid_compare_same_value_rule.dart';
import 'package:my_lints/src/rules/avoid_complex_loop_conditions_rule.dart';
import 'package:my_lints/src/rules/avoid_dynamic_type_rule.dart';
import 'package:my_lints/src/rules/avoid_enum_values_by_index_rule.dart';
import 'package:my_lints/src/rules/avoid_invert_condition_rule.dart';
import 'package:my_lints/src/rules/avoid_map_keys_contains_rule.dart';
import 'package:my_lints/src/rules/avoid_mutating_parameter_rule.dart';
import 'package:my_lints/src/rules/avoid_nested_if_rule.dart';
import 'package:my_lints/src/rules/avoid_nested_record_rule.dart';
import 'package:my_lints/src/rules/avoid_mixing_named_and_positional_fields.dart';
import 'package:my_lints/src/rules/avoid_nested_switch_expression_rule.dart';
import 'package:my_lints/src/rules/avoid_nullable_list_return_type_rule.dart';
import 'package:my_lints/src/rules/avoid_positional_record_field_access_rule.dart';
import 'package:my_lints/src/rules/avoid_nullable_bool_rule.dart';
import 'package:my_lints/src/rules/avoid_reduce_usage_rule.dart';
import 'package:my_lints/src/rules/avoid_returning_value_from_cubit_methods_rule.dart';
import 'package:my_lints/src/rules/avoid_shadowed_extension_methods_rule.dart';
import 'package:my_lints/src/rules/avoid_useless_async_method_rule.dart';
import 'package:my_lints/src/rules/controller_dispose_rule.dart';
import 'package:my_lints/src/rules/prefer_addition_subtraction_assignments_rule.dart';
import 'package:my_lints/src/rules/prefer_any_or_every_rule.dart';
import 'package:my_lints/src/rules/prefer_contains_rule.dart';
import 'package:my_lints/src/rules/prefer_correct_callback_field_name_rule.dart';
import 'package:my_lints/src/rules/prefer_explicit_function_type_rule.dart';
import 'package:my_lints/src/rules/prefer_first_rule.dart';
import 'package:my_lints/src/rules/prefer_is_empty_rule.dart';
import 'package:my_lints/src/rules/prefer_last_rule.dart';
import 'package:my_lints/src/rules/prefer_null_aware_notation_rule.dart';
import 'package:my_lints/src/rules/prefer_null_aware_spread_rule.dart';
import 'package:my_lints/src/rules/prefer_throw_exception_or_error_rule.dart';
import 'package:my_lints/src/rules/prefer_usage_of_value_getter_rule.dart';
import 'package:my_lints/src/rules/prefer_void_callback.dart';
import 'package:my_lints/src/rules/use_join_on_strings_rule.dart';

final plugin = MyLintsPlugin();

class MyLintsPlugin extends Plugin {
  @override
  String get name => 'My Lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(PreferExplicitFunctionType())
      ..registerWarningRule(PreferFirstRule())
      ..registerWarningRule(PreferLastRule())
      ..registerWarningRule(PreferAnyOrEvery())
      ..registerWarningRule(PreferIsEmptyRule())
      ..registerWarningRule(PreferNullAwareSpreadRule())
      ..registerWarningRule(AvoidMixingNamedAndPositionalFields())
      ..registerWarningRule(AvoidNestedSwitchExpressionRule())
      ..registerWarningRule(AvoidNestedRecordRule())
      ..registerWarningRule(AvoidUselessAsyncMethodRule())
      ..registerWarningRule(PreferNullAwareSpreadRule())
      ..registerWarningRule(AvoidInvertConditionRule())
      ..registerWarningRule(PreferContainsRule())
      ..registerWarningRule(AvoidNullableListReturnTypeRule())
      ..registerWarningRule(PreferIsEmptyRule())
      ..registerWarningRule(AvoidPositionalRecordFieldAccessRule())
      ..registerWarningRule(AvoidDynamicTypeRule())
      ..registerWarningRule(AvoidEnumValuesByIndexRule())
      ..registerWarningRule(ControllerDisposeRule())
      ..registerWarningRule(PreferNullAwareNotationRule())
      ..registerWarningRule(PreferVoidCallbackRule())
      ..registerWarningRule(AvoidNullableBoolRule())
      ..registerWarningRule(AvoidMapKeysContainsRule())
      ..registerWarningRule(AvoidShadowedExtensionMethodsRule())
      ..registerWarningRule(PreferUsageOfValueGetterRule())
      ..registerWarningRule(PreferCorrectCallbackFieldNameRule())
      ..registerWarningRule(AvoidMutatingParametersRule())
      ..registerWarningRule(AvoidCompareSameValueRule())
      ..registerWarningRule(AvoidReduceUsageRule())
      ..registerWarningRule(UseJoinOnStringsRule())
      ..registerWarningRule(AvoidReturningValueFromCubitMethodsRule())
      ..registerWarningRule(PreferThrowExceptionOrErrorRule())
      ..registerWarningRule(AvoidComplexLoopConditionsRule())
      ..registerWarningRule(AvoidNestedIfRule())
      ..registerWarningRule(PreferAdditionSubtractionAssignmentsRule());

    registry
      ..registerFixForRule(PreferAnyOrEvery.code, PreferAnyOrEveryFix.new)
      ..registerFixForRule(AvoidInvertConditionRule.code, AvoidInvertConditionFix.new)
      ..registerFixForRule(PreferContainsRule.code, PreferContainsFix.new)
      ..registerFixForRule(PreferLastRule.code, PreferLastFix.new)
      ..registerFixForRule(AvoidEnumValuesByIndexRule.code, AvoidEnumValuesByIndexFix.new)
      ..registerFixForRule(PreferExplicitFunctionType.code, PreferExplicitFunctionTypeFix.new)
      ..registerFixForRule(PreferUsageOfValueGetterRule.code, PreferUsageOfValueGetterFix.new)
      ..registerFixForRule(PreferAdditionSubtractionAssignmentsRule.code, PreferAdditionSubtractionAssignmentsFix.new)
      ..registerFixForRule(PreferFirstRule.code, PreferFirstFix.new);
  }
}
