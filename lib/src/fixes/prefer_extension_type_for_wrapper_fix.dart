import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferExtensionTypeForWrapperFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferExtensionTypeForWrapper',
    DartFixKindPriority.standard,
    'Replace with extension type',
  );

  PreferExtensionTypeForWrapperFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node as ClassDeclaration;
    final className = node.name.lexeme;

    // Find the single wrapper field.
    final fields = node.members.whereType<FieldDeclaration>().where((f) => !f.isStatic).toList();
    if (fields.length != 1) return;
    final variable = fields.first.fields.variables.first;
    final fieldName = variable.name.lexeme;
    final fieldType = fields.first.fields.type?.toSource() ?? 'dynamic';

    // Collect non-constructor, non-wrapper-field members (getters, methods) to keep inside the extension type.
    final nonConstructorMembers = node.members
        .where((m) => m is! ConstructorDeclaration && m is! FieldDeclaration)
        .toList();

    final buffer = StringBuffer()..write('extension type $className($fieldType $fieldName)');

    if (nonConstructorMembers.isNotEmpty) {
      buffer.write(' {\n');
      for (final member in nonConstructorMembers) {
        buffer.write(member.toSource());
        buffer.write('\n');
      }
      buffer.write('}');
    }

    await builder.addDartFileEdit(file, (builder) {
      builder
        ..addSimpleReplacement(range.node(node), buffer.toString())
        ..format(range.node(node));
    });
  }
}
