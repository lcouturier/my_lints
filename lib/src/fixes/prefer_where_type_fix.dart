// ignore_for_file: unused_element

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferWhereTypeFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferWhereType',
    DartFixKindPriority.standard,
    'Replace with whereType',
  );

  PreferWhereTypeFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final m = node as MethodInvocation;

    // items.where((x) => x is String);
    if (m case MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?)) {
      final targetType = target.staticType;
      if (targetType is! InterfaceType || targetType.typeArguments.length != 1) {
        return;
      }
      final elementType = targetType.typeArguments.first;
      final nonNullable = elementType.getDisplayString(withNullability: false);

      final String replacement = '${m.target}.whereType<$nonNullable>()';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(m), replacement);
      });
      return;
    }
    // items.where((x) => x is String).cast<String>();
    if (m case MethodInvocation(
      methodName: SimpleIdentifier(name: 'cast'),
      target: MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?),
    )) {
      final whereInvocation = m.target as MethodInvocation;
      final whereType = whereInvocation.whereType;
      if (whereType == null) {
        return;
      }
      final nonNullable = whereType.getDisplayString(withNullability: false);

      final replacement = '$target.whereType<$nonNullable>()';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(m), replacement);
      });
      return;
    }

    if (m case MethodInvocation(
      methodName: SimpleIdentifier(name: 'map'),
      target: MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?),
    ) when m.isMapWithCast) {
      final whereInvocation = m.target as MethodInvocation;
      final whereType = whereInvocation.whereType;
      if (whereType == null) {
        return;
      }
      final nonNullable = whereType.getDisplayString(withNullability: false);

      final replacement = '$target.whereType<$nonNullable>()';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(m), replacement);
      });
      return;
    }
  }
}

class PreferWhereTypeFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferWhereTypeInFile',
    DartFixKindPriority.inFile,
    'Replace all with whereType',
  );

  PreferWhereTypeFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferWhereTypeVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences.whereType<MethodInvocation>()) {
        final m = occurrence;
        if (m case MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?)) {
          final targetType = target.staticType;
          if (targetType is! InterfaceType || targetType.typeArguments.length != 1) {
            return;
          }
          final elementType = targetType.typeArguments.first;
          final nonNullable = elementType.getDisplayString(withNullability: false);
          final String replacement = '${m.target}.whereType<$nonNullable>()';

          builder.addSimpleReplacement(range.node(m), replacement);
        } else if (m case MethodInvocation(
          methodName: SimpleIdentifier(name: 'cast'),
          target: MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?),
        )) {
          final whereInvocation = m.target as MethodInvocation;
          final whereType = whereInvocation.whereType;
          if (whereType == null) {
            return;
          }
          final nonNullable = whereType.getDisplayString(withNullability: false);
          final replacement = '$target.whereType<$nonNullable>()';

          builder.addSimpleReplacement(range.node(m), replacement);
        } else if (m case MethodInvocation(
          methodName: SimpleIdentifier(name: 'map'),
          target: MethodInvocation(methodName: SimpleIdentifier(name: 'where'), :final target?),
        ) when m.isMapWithCast) {
          final whereInvocation = m.target as MethodInvocation;
          final whereType = whereInvocation.whereType;
          if (whereType == null) {
            return;
          }
          final nonNullable = whereType.getDisplayString(withNullability: false);
          final replacement = '$target.whereType<$nonNullable>()';

          builder.addSimpleReplacement(range.node(m), replacement);
        }
      }
    });
  }
}

class _PreferWhereTypeVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'where'),
      argumentList: ArgumentList(arguments: final arguments),
    ) when arguments.length == 1) {
      occurrences.add(node);
    }
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'cast'),
      target: MethodInvocation(methodName: SimpleIdentifier(name: 'where')),
    )) {
      occurrences.add(node);
    }
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'map'),
      target: MethodInvocation(methodName: SimpleIdentifier(name: 'where')),
    ) when node.isMapWithCast) {
      occurrences.add(node);
    }
  }
}
