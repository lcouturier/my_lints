import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferUsageOfValueGetterFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.prefer_usage_of_value_getter',
    DartFixKindPriority.standard,
    'Use value getter',
  );

  PreferUsageOfValueGetterFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node as GenericFunctionType;
    final isNodeNullable = targetNode.question != null;

    final returnType = targetNode.returnType;
    final typeName = (returnType! as NamedType).name.lexeme;
    // final isNullable = (returnType as NamedType).question != null;

    final replacement = 'ValueGetter<$typeName>${isNodeNullable ? '?' : ''}';

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
        ..addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}
