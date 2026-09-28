import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferIsEmptyFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferIsEmpty',
    DartFixKindPriority.standard,
    'Replace with isEmpty/isNotEmpty',
  );

  PreferIsEmptyFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node is! BinaryExpression) return;
    final target = (node as BinaryExpression);
    if (target.isLengthComparison) {
      final String replacement = (node as BinaryExpression).operator.type == TokenType.EQ_EQ
          ? '${target.targetName}.isEmpty'
          : '${target.targetName}.isNotEmpty';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(node), replacement);
      });
    }
  }
}

class PreferIsEmptyFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferIsEmptyInFile',
    DartFixKindPriority.inFile,
    'Replace all == 0 with isEmpty or != 0 with isNotEmpty in file...',
  );

  PreferIsEmptyFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferEmptyVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final node in visitor.occurrences) {
        final String replacement = node.operator.type == TokenType.EQ_EQ
            ? '${node.targetName}.isEmpty'
            : '${node.targetName}.isNotEmpty';
        builder.addSimpleReplacement(range.node(node), replacement);
      }
    });
  }
}

class _PreferEmptyVisitor extends RecursiveAstVisitor<void> {
  final List<BinaryExpression> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(leftOperand: (PropertyAccess(target: StringLiteral())))) return;
    if (node case BinaryExpression(leftOperand: (PropertyAccess(target: ListLiteral())))) return;
    if (node.isLengthComparison) {
      occurrences.add(node);
    }
    super.visitBinaryExpression(node);
  }
}

extension on BinaryExpression {
  String get targetName {
    if (this case BinaryExpression(
      leftOperand: (PropertyAccess(
            target: SimpleIdentifier(name: final targetName),
            propertyName: SimpleIdentifier(name: 'length'),
          ) ||
          PrefixedIdentifier(
            prefix: SimpleIdentifier(name: final targetName),
            identifier: SimpleIdentifier(name: 'length'),
          )),
    )) {
      return targetName;
    }
    return '';
  }
}
