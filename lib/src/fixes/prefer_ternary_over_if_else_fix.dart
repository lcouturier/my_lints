import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferTernaryOverIfElseFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferTernaryOverIfElse',
    DartFixKindPriority.standard,
    'Replace with ternary operator',
  );

  PreferTernaryOverIfElseFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  ReturnStatement? _extractReturn(Statement? statement) {
    return switch (statement) {
      ReturnStatement() => statement,
      Block(statements: [final ReturnStatement returnStmt]) => returnStmt,
      _ => null,
    };
  }

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! IfStatement) return;

    final left = _extractReturn(targetNode.thenStatement)?.expression;
    final right = _extractReturn(targetNode.elseStatement)?.expression;
    if (left == null || right == null) return;

    final condition = targetNode.expression.unParenthesized.toSource();
    final thenExpr = left.unParenthesized.toSource();
    final elseExpr = right.unParenthesized.toSource();

    final replacement = 'return $condition ? $thenExpr : $elseExpr;';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}
