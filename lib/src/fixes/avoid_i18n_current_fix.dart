import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/helpers.dart';

class AvoidI18nCurrentFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidI18nCurrent',
    DartFixKindPriority.standard,
    'Replace I18n.current with I18n.of(context)...',
  );

  static const String badWay = 'I18n.current.';

  AvoidI18nCurrentFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final access = node.thisOrAncestorMatching(isI18nCurrentAccess);
    if (access == null) return;

    final contextName = getContextName(access);
    if (contextName == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(access), 'I18n.of($contextName)');
    });
  }
}

class AvoidI18nCurrentFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidI18nCurrentInFile',
    DartFixKindPriority.inFile,
    'Replace all I18n.current with I18n.of(context) in file...',
  );

  AvoidI18nCurrentFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _I18nCurrentVisitor();
    unit.accept(visitor);

    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences) {
        builder.addSimpleReplacement(range.node(occurrence.node), 'I18n.of(${occurrence.contextName})');
      }
    });
  }
}

typedef _I18nOccurrence = ({AstNode node, String contextName});

class _I18nCurrentVisitor extends RecursiveAstVisitor<void> {
  final List<_I18nOccurrence> occurrences = [];

  _I18nCurrentVisitor();

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _addOccurrence(node);
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _addOccurrence(node);
    super.visitPrefixedIdentifier(node);
  }

  void _addOccurrence(AstNode node) {
    if (!isI18nCurrentAccess(node)) return;

    final contextName = getContextName(node);
    if (contextName != null) {
      occurrences.add((node: node, contextName: contextName));
    }
  }
}
