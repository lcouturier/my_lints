import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class AvoidRedundantMapFromFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidRedundantMapFrom',
    DartFixKindPriority.standard,
    'Remove redundant map.from',
  );

  AvoidRedundantMapFromFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final arg = (node as InstanceCreationExpression).argumentList.arguments.first;

    final replacement = '{...$arg}';
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(node), replacement);
    });
  }
}

class AvoidRedundantMapFromFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidRedundantMapFromInFile',
    DartFixKindPriority.inFile,
    'Replace all map.from in file...',
  );

  AvoidRedundantMapFromFixInFile({required super.context});

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
      for (final node in visitor.occurrences.whereType<InstanceCreationExpression>()) {
        final arg = node.argumentList.arguments.first;
        final replacement = '{...$arg}';
        builder.addSimpleReplacement(range.node(node), replacement);
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'Map')), name: Identifier(name: 'from')),
      argumentList: ArgumentList(arguments: [Identifier()]),
    )) {
      occurrences.add(node);
    }
  }
}
