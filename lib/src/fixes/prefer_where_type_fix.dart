import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

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
    final targetType = m.target?.staticType;
    if (targetType is! InterfaceType || targetType.typeArguments.length != 1) {
      return;
    }
    final elementType = targetType.typeArguments.first;
    final nonNullable = elementType.getDisplayString(withNullability: false);

    final String replacement = '${m.target}.whereType<$nonNullable>()';
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(m), replacement);
    });
  }
}
