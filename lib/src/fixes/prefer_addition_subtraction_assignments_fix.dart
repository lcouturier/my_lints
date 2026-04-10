import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferAdditionSubtractionAssignmentsFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferAdditionSubtractionAssignments',
    DartFixKindPriority.standard,
    'Replace with += 1 or -= 1',
  );

  PreferAdditionSubtractionAssignmentsFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! PostfixExpression) return;
    if (targetNode.operator.type != TokenType.PLUS_PLUS && targetNode.operator.type != TokenType.MINUS_MINUS) return;

    final String replacement = targetNode.operator.type == TokenType.PLUS_PLUS
        ? '${targetNode.operand} += 1'
        : '${targetNode.operand} -= 1';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}
