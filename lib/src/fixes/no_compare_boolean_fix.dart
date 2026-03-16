import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class NoCompareBooleanFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.noCompareBoolean',
    DartFixKindPriority.standard,
    'Remove the unnecessary comparison to boolean literals',
  );

  NoCompareBooleanFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! BinaryExpression) return;

    final replacement = switch ((
      targetNode.operator.type == TokenType.EQ_EQ,
      (targetNode.rightOperand as BooleanLiteral).value,
    )) {
      (true, true) => targetNode.leftOperand.toString(),
      (true, false) => '!${targetNode.leftOperand.toString()}',
      (false, true) => '!${targetNode.leftOperand.toString()}',
      (false, false) => targetNode.leftOperand.toString(),
    };

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}
