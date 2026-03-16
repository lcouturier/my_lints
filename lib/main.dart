library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:my_lints/src/rules/avoid_nested_if_rule.dart';
import 'package:my_lints/src/rules/avoid_nested_record_rule.dart';
import 'package:my_lints/src/rules/avoid_nested_switch_expression_rule.dart';
import 'package:my_lints/src/rules/avoid_useless_async_method_rule.dart';
import 'package:my_lints/src/rules/prefer_explicit_function_type_rule.dart';
import 'package:my_lints/src/rules/prefer_first_rule.dart';
import 'package:my_lints/src/rules/prefer_null_aware_spread_rule.dart';

final plugin = MyLints();

class MyLints extends Plugin {
  @override
  String get name => 'My Lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(PreferExplicitFunctionType())
      ..registerWarningRule(PreferFirstRule())
      ..registerWarningRule(AvoidNestedSwitchExpressionRule())
      ..registerWarningRule(AvoidUselessAsyncMethodRule())
      ..registerWarningRule(AvoidNestedRecordRule())
      ..registerWarningRule(PreferNullAwareSpreadRule())
      ..registerWarningRule(AvoidNestedIfRule());
  }
}
