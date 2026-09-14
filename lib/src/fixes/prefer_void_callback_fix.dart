import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferVoidCallbackFix extends ResolvedCorrectionProducer {
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
    if (node case GenericFunctionType(
      typeParameters: null,
      parameters: FormalParameterList(parameters: []),
      :final returnType,
      :final question,
    ) when returnType is NamedType) {
      if (returnType.typeArguments?.arguments.isNotEmpty ?? false) return;

      if (returnType.name.lexeme == 'void') {
        await builder.addDartFileEdit(file, (builder) {
          builder
            ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
            ..addSimpleReplacement(range.node(node), 'VoidCallback${question != null ? '?' : ''}');
        });
      }
      if (returnType.name.lexeme != 'void') {
        final typeName = returnType.name.lexeme;
        final isNullable = returnType.question != null;
        final replacement = 'ValueGetter<${isNullable ? '$typeName?' : typeName}>${question != null ? '?' : ''}';

        await builder.addDartFileEdit(file, (builder) {
          builder
            ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
            ..addSimpleReplacement(range.node(node), replacement);
        });
      }
    }
  }
}

class PreferVoidCallbackFixInFile extends ResolvedCorrectionProducer {
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
      for (final occurrence in visitor.occurrences.whereType<GenericFunctionType>()) {
        if (occurrence case GenericFunctionType(
          typeParameters: null,
          parameters: FormalParameterList(parameters: []),
          :final returnType?,
          :final question,
        ) when returnType is NamedType) {
          if (returnType.typeArguments?.arguments.isNotEmpty ?? false) continue;
          if (returnType.name.lexeme == 'void') {
            builder
              ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
              ..addSimpleReplacement(range.node(occurrence), 'VoidCallback${question != null ? '?' : ''}');
          } else {
            final typeName = returnType.name.lexeme;
            final isNullable = returnType.question != null;
            final replacement = 'ValueGetter<${isNullable ? '$typeName?' : typeName}>${question != null ? '?' : ''}';
            builder
              ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
              ..addSimpleReplacement(range.node(occurrence), replacement);
          }
        }
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    if (node case GenericFunctionType(
      typeParameters: null,
      parameters: FormalParameterList(parameters: []),
      :final returnType?,
    ) when returnType is NamedType) {
      occurrences.add(node);
    }

    super.visitGenericFunctionType(node);
  }
}
