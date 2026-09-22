import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferNullCoalescingOperatorFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullCoalescingOperator',
    DartFixKindPriority.standard,
    'Replace with null coalescing operator (??)',
  );

  PreferNullCoalescingOperatorFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! ConditionalExpression) return;

    final condition = targetNode.condition;
    if (condition is! BinaryExpression) return;

    final replacement = "${condition.leftOperand.toSource()} ?? ${targetNode.elseExpression.toSource()}";

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

class PreferNullCoalescingOperatorFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullCoalescingOperatorInFile',
    DartFixKindPriority.inFile,
    'Replace all null checks with null coalescing operator in file...',
  );

  PreferNullCoalescingOperatorFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferNullCoalescingOperatorVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences.whereType<ConditionalExpression>()) {
        final condition = occurrence.condition as BinaryExpression;

        final replacement = "${condition.leftOperand.toSource()} ?? ${occurrence.elseExpression.toSource()}";
        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
    });
  }
}

class _PreferNullCoalescingOperatorVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node case ConditionalExpression(
      condition: BinaryExpression(
        leftOperand: SimpleIdentifier(name: final leftName),
        operator: Token(type: TokenType.BANG_EQ),
        rightOperand: NullLiteral(),
      ),
      thenExpression: SimpleIdentifier(name: final thenName),
    ) when leftName == thenName) {
      occurrences.add(node);
    }
  }
}
