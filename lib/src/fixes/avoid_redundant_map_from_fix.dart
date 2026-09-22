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
    'Replace by spread operator',
  );

  AvoidRedundantMapFromFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: final type))),
      argumentList: ArgumentList(arguments: [Identifier(name: final arg)]),
    )) {
      final replacement = switch (type) {
        'List' => '[...$arg]',
        _ => '{...$arg}',
      };
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(node), replacement);
      });
    }
  }
}

class AvoidRedundantMapFromFixInFile extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidRedundantMapFromInFile',
    DartFixKindPriority.inFile,
    "Replace all with spread operator",
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
        if (node case InstanceCreationExpression(
          constructorName: ConstructorName(type: NamedType(name: Token(lexeme: final type))),
          argumentList: ArgumentList(arguments: [Identifier(name: final arg)]),
        )) {
          final replacement = switch (type) {
            'List' => '[...$arg]',
            _ => '{...$arg}',
          };
          builder.addSimpleReplacement(range.node(node), replacement);
        }
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  static const _targetTypes = {'List', 'Set', 'Map'};
  static const _targetConstructors = {'from', 'of'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: final type)), name: Identifier(:final name)),
      argumentList: ArgumentList(arguments: [Identifier()]),
    ) when _targetTypes.contains(type) && _targetConstructors.contains(name)) {
      occurrences.add(node);
    }
  }
}
