import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
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
    if (node case final BinaryExpression target when target.isEmptinessComparison) {
      final String replacement = _replacementFor(target);

      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(target), replacement);
      });
    }
  }
}

class PreferIsEmptyFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferIsEmptyInFile',
    DartFixKindPriority.inFile,
    'Replace all length comparisons with isEmpty/isNotEmpty in file...',
  );

  PreferIsEmptyFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferIsEmptyVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final BinaryExpression occurrence in visitor.occurrences) {
        builder.addSimpleReplacement(range.node(occurrence), _replacementFor(occurrence));
      }
    });
  }
}

/// The receiver always is a postfix or parenthesized expression, so its source needs no extra parentheses.
String _replacementFor(BinaryExpression node) =>
    '${node.lengthComparisonTarget!.toSource()}.${node.emptinessGetterName}';

class _PreferIsEmptyVisitor extends RecursiveAstVisitor<void> {
  final List<BinaryExpression> occurrences = <BinaryExpression>[];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.isEmptinessComparison) {
      occurrences.add(node);
    }
    super.visitBinaryExpression(node);
  }
}
