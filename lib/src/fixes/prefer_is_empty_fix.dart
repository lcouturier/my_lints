import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

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
    if (node case BinaryExpression(
      leftOperand: (PropertyAccess(
            target: SimpleIdentifier(name: final targetName),
            propertyName: SimpleIdentifier(name: 'length'),
          ) ||
          PrefixedIdentifier(
            prefix: SimpleIdentifier(name: final targetName),
            identifier: SimpleIdentifier(name: 'length'),
          )),
      operator: (Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ)) && final operator,
      rightOperand: IntegerLiteral(value: 0),
    )) {
      final String replacement = operator.type == TokenType.EQ_EQ ? '$targetName.isEmpty' : '$targetName.isNotEmpty';
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
        if (node case BinaryExpression(
          leftOperand: (PropertyAccess(
                target: SimpleIdentifier(name: final targetName),
                propertyName: SimpleIdentifier(name: 'length'),
              ) ||
              PrefixedIdentifier(
                prefix: SimpleIdentifier(name: final targetName),
                identifier: SimpleIdentifier(name: 'length'),
              )),
          operator: (Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ)) && final operator,
          rightOperand: IntegerLiteral(value: 0),
        )) {
          final String replacement = operator.type == TokenType.EQ_EQ
              ? '$targetName.isEmpty'
              : '$targetName.isNotEmpty';
          builder.addSimpleReplacement(range.node(node), replacement);
        }
      }
    });
  }
}

class _PreferEmptyVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      leftOperand: (PropertyAccess(propertyName: SimpleIdentifier(name: 'length')) ||
          PrefixedIdentifier(identifier: SimpleIdentifier(name: 'length'))),
      operator: Token(type: TokenType.EQ_EQ) || Token(type: TokenType.BANG_EQ),
      rightOperand: IntegerLiteral(value: 0),
    )) {
      occurrences.add(node);
    }
    super.visitBinaryExpression(node);
  }
}
