import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:my_lints/src/common/equatable_props.dart';
import 'package:my_lints/src/common/extensions.dart';

class EquatablePropsMustIncludeAllFieldsFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.equatablePropsMustIncludeAllFields',
    DartFixKindPriority.standard,
    'Add missing fields to props',
  );

  EquatablePropsMustIncludeAllFieldsFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final propsMethod = node.thisOrAncestorOfType<MethodDeclaration>();
    final declaration = propsMethod?.thisOrAncestorOfType<ClassDeclaration>();
    final propsList = propsMethod == null ? null : equatablePropsList(propsMethod);
    if (declaration == null || !declaration.isEquatable || propsList == null) return;

    final missingFields = declaration.fields.difference(equatablePropsFields(propsList)).toList()..sort();
    if (missingFields.isEmpty) return;

    final (:offset, :text) = _insertion(propsList, missingFields);
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(offset, text);
    });
  }

  ({int offset, String text}) _insertion(ListLiteral propsList, List<String> missingFields) {
    final elements = propsList.elements;
    if (elements.isEmpty) {
      return (offset: propsList.leftBracket.end, text: missingFields.join(', '));
    }

    final trailingComma = propsList.rightBracket.previous?.type == TokenType.COMMA
        ? propsList.rightBracket.previous
        : null;
    final lastElement = elements.last;
    final isMultiline =
        unitResult.lineInfo.getLocation(lastElement.offset).lineNumber !=
        unitResult.lineInfo.getLocation(propsList.leftBracket.offset).lineNumber;

    if (!isMultiline) {
      return (offset: trailingComma?.offset ?? propsList.rightBracket.offset, text: ', ${missingFields.join(', ')}');
    }

    final indentation = utils.getLinePrefix(lastElement.offset);
    final fields = missingFields.map((field) => '$indentation$field,').join('\n');
    return (offset: trailingComma?.end ?? lastElement.end, text: '${trailingComma == null ? ',' : ''}\n$fields');
  }
}
