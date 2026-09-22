import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferNullAwareElementsFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareElements',
    DartFixKindPriority.standard,
    'Replace with null-aware elements (\'...?\')',
  );

  PreferNullAwareElementsFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode case IfElement(thenElement: SimpleIdentifier(:final name))) {
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(targetNode), '?$name');
      });
    }
  }
}
