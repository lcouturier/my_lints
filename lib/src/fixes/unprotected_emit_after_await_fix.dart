import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class UnProtectedEmitAfterAwaitReplaceFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.unprotectedEmitAfterAwaitReplace',
    DartFixKindPriority.standard,
    "Add 'if (!isClosed)' guard",
  );

  UnProtectedEmitAfterAwaitReplaceFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;

    final replacement = 'if (!isClosed) ${targetNode.toSource()}';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

class UnProtectedEmitAfterAwaitInsertFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.unprotectedEmitAfterAwaitInsert',
    DartFixKindPriority.standard,
    "Add 'if isClosed' guard",
  );

  UnProtectedEmitAfterAwaitInsertFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;

    final statement = targetNode.thisOrAncestorOfType<Statement>();
    if (statement == null) return;

    final insertion = 'if (isClosed) return;\n';

    await builder.addDartFileEdit(file, (builder) {
      final formatRange = SourceRange(statement.offset, statement.length + insertion.length);
      builder
        ..addSimpleInsertion(statement.offset, insertion)
        ..format(formatRange);
    });
  }
}
