import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/rules/prefer_void_callback_rule.dart';

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
  String getReplacement(GenericFunctionType node) {
    final returnType = node.returnType;
    final isNullable = node.question != null;
    final typeName = returnType is NamedType ? returnType.name.lexeme : 'void';
    return switch (returnType) {
      NamedType(name: Token(:final lexeme)) when lexeme != 'void' =>
        'ValueGetter<${isNullable ? '$typeName?' : typeName}>${node.question != null ? '?' : ''}',
      NamedType(name: Token(:final lexeme)) when lexeme == 'void' => 'VoidCallback${node.question != null ? '?' : ''}',
      _ => 'VoidCallback${node.question != null ? '?' : ''}',
    };
  }
}
