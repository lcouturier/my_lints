import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class AvoidEnumValuesByIndexFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidEnumValuesByIndex',
    DartFixKindPriority.standard,
    'Use enum constant directly',
  );

  AvoidEnumValuesByIndexFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node is! IndexExpression) return;
    final indexExpr = node as IndexExpression;
    final targetNode = indexExpr.target;

    if (targetNode is! PrefixedIdentifier) return;
    final enumValues = (targetNode.prefix.element as EnumElement);
    final index = (indexExpr.index as IntegerLiteral).value;

    final value = enumValues.constants.elementAt(index!).displayName;
    final replacement = "${enumValues.name}.$value";

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(node), replacement);
    });
  }
}
