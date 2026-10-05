import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/rules/types/prefer_void_callback_rule.dart';

class PreferVoidCallbackFix extends ResolvedCorrectionProducer with ReplaceByVoidCallback {
  static const _fixKind = FixKind(
    'my_lints.fix.preferVoidCallback',
    DartFixKindPriority.standard,
    'Replace Generic Function',
  );

  PreferVoidCallbackFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final GenericFunctionType type when type.isReplaceableByCallbackAlias) {
      await builder.addDartFileEdit(file, (builder) {
        builder.importLibraryElement(Uri.parse('package:flutter/material.dart'));
        builder.addSimpleReplacement(range.node(type), getReplacement(type));
      });
    }
  }
}

class PreferVoidCallbackFixInFile extends ResolvedCorrectionProducer with ReplaceByVoidCallback {
  static const _fixKind = FixKind(
    'my_lints.fix.preferVoidCallbackInFile',
    DartFixKindPriority.inFile,
    'Replace all Generic Function in file...',
  );

  PreferVoidCallbackFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _Visitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.importLibraryElement(Uri.parse('package:flutter/material.dart'));
      for (final occurrence in visitor.occurrences) {
        builder.addSimpleReplacement(range.node(occurrence), getReplacement(occurrence));
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<GenericFunctionType> occurrences = [];

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    if (node.isReplaceableByCallbackAlias) {
      occurrences.add(node);
    }

    super.visitGenericFunctionType(node);
  }
}

mixin ReplaceByVoidCallback {
  /// Returns the replacement string for a given [GenericFunctionType] node.
  /// If the return type is `void` or unspecified, it returns `VoidCallback`.
  /// Otherwise, it returns `ValueGetter<ReturnType>`.
  /// The returned string includes a `?` suffix if the original function type is nullable.
  /// Example:
  /// ```dart
  /// int Function() f; // becomes ValueGetter<int>
  /// void Function() f; // becomes VoidCallback
  /// int? Function() f; // becomes ValueGetter<int?>
  /// void Function()? f; // becomes VoidCallback?
  /// ```
  String getReplacement(GenericFunctionType node) {
    final suffix = node.question != null ? '?' : '';
    final returnType = node.returnType;

    if (returnType == null || returnType.toSource() == 'void') {
      return 'VoidCallback$suffix';
    }

    return 'ValueGetter<${returnType.toSource()}>$suffix';
  }
}
