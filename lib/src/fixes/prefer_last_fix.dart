import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/rules/prefer_last_rule.dart';

class PreferLastFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind('my_lints.fix.preferLast', DartFixKindPriority.standard, 'Replace with .last');

  PreferLastFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is MethodInvocation) {
      final String replacement = '${targetNode.target}.last';

      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(targetNode), replacement);
      });
    }

    if (targetNode is IndexExpression) {
      final String replacement = '${targetNode.target}.last';

      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(targetNode), replacement);
      });
    }
  }
}

class PreferLastFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferLastInFile',
    DartFixKindPriority.inFile,
    'Replace with .last in file',
  );

  PreferLastFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _PreferLastVisitor();
    unit.accept(visitor);
    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences.whereType<IndexExpression>()) {
        final String replacement = '${occurrence.target}.last';
        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
      for (final occurrence in visitor.occurrences.whereType<MethodInvocation>()) {
        final String replacement = '${occurrence.target}.last';
        builder.addSimpleReplacement(range.node(occurrence), replacement);
      }
    });
  }
}

class _PreferLastVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.isLastElementAccess) {
      occurrences.add(node);
    }

    super.visitIndexExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.isLastElementAccess) {
      occurrences.add(node);
    }

    super.visitMethodInvocation(node);
  }
}
