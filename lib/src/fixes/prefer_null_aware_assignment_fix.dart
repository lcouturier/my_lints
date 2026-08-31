import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferNullAwareAssignmentFix extends ResolvedCorrectionProducer with _PreferNullAwareAssignmentMixin {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareAssignment',
    DartFixKindPriority.inFile,
    'Prefer null-aware assignment',
  );

  PreferNullAwareAssignmentFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node as IfStatement;
    final replacement = this.replacement(node);

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(node), (b) => b.write(replacement));
    });
  }

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;
}

class PreferNullAwareAssignmentFixInFile extends ResolvedCorrectionProducer with _PreferNullAwareAssignmentMixin {
  static const _fixKind = FixKind(
    'my_lints.fix.preferNullAwareAssignmentInFile',
    DartFixKindPriority.inFile,
    'Replace all null-aware assignment in file',
  );

  PreferNullAwareAssignmentFixInFile({required super.context});

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
      for (final occurrence in visitor.occurrences.whereType<IfStatement>()) {
        final replacement = this.replacement(occurrence);
        builder.addReplacement(range.node(occurrence), (b) => b.write(replacement));
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final List<AstNode> occurrences = [];

  @override
  void visitIfStatement(IfStatement node) {
    if (node.expression case BinaryExpression(
      leftOperand: SimpleIdentifier(:final name),
      operator: Token(type: TokenType.EQ_EQ),
      rightOperand: NullLiteral(),
    )) {
      final thenStatement = node.thenStatement;
      if (thenStatement case Block(:final statements) when statements.length == 1) {
        final actualStatement = statements.single;
        if (actualStatement case ExpressionStatement(
          expression: AssignmentExpression(
            leftHandSide: SimpleIdentifier(name: final exprName),
            operator: Token(type: TokenType.EQ),
          ),
        ) when name == exprName) {
          occurrences.add(node);
        }
      }
    }
    super.visitIfStatement(node);
  }
}

mixin _PreferNullAwareAssignmentMixin {
  String replacement(IfStatement node) {
    final name = (node.expression as BinaryExpression).leftOperand as SimpleIdentifier;
    final thenStatement = node.thenStatement;
    final actualStatement = (thenStatement as Block).statements.single;
    final rightValue = ((actualStatement as ExpressionStatement).expression as AssignmentExpression).rightHandSide;

    return '$name ??= $rightValue;';
  }
}
