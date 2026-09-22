import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferNullAwareNotationFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareNotation',
    DartFixKindPriority.inFile,
    'Prefer null-aware notation',
  );

  PreferNullAwareNotationFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! BinaryExpression) return;

    final leftOperand = node.leftOperand;
    final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;
    final replacement = isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)';

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(node), (b) => b.write(replacement));
    });
  }

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;
}

class PreferNullAwareNotationFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareNotationInFile',
    DartFixKindPriority.inFile,
    'Replace all null-aware notation in file',
  );

  PreferNullAwareNotationFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _Visitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences.whereType<BinaryExpression>()) {
        final leftOperand = occurrence.leftOperand;
        final isCheckingTrue = (occurrence.rightOperand as BooleanLiteral).value;
        final replacement = isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)';

        builder.addReplacement(range.node(occurrence), (b) => b.write(replacement));
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(leftOperand: final expr, operator: Token(type: final operatorType))
        when (operatorType == TokenType.EQ_EQ || operatorType == TokenType.BANG_EQ) &&
            (expr.staticType?.isNullable ?? false)) {
      occurrences.add(node);
    }
    super.visitBinaryExpression(node);
  }
}
