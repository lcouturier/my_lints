import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Fix that replaces .where().isEmpty/isNotEmpty with .any()/.every().
class PreferAnyOrEveryFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferAnyOrEvery',
    DartFixKindPriority.standard,
    'Replace with any()/every()',
  );

  PreferAnyOrEveryFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    if (targetNode is! PropertyAccess) return;

    final property = targetNode.propertyName.name;
    final whereInvocation = targetNode.target;
    if (whereInvocation is! MethodInvocation) return;

    final collection = whereInvocation.target;
    if (collection == null) return;

    final predicate = whereInvocation.argumentList.arguments.firstOrNull;
    if (predicate == null) return;

    final isNotEmpty = property == 'isNotEmpty';
    final String replacement;

    if (isNotEmpty) {
      replacement = '${collection.toSource()}.any(${predicate.toSource()})';
    } else {
      final everyReplacement = buildEveryReplacement(collection.toSource(), predicate);
      if (everyReplacement == null) return;
      replacement = everyReplacement;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(targetNode), replacement);
    });
  }
}

/// Builds a replacement expression for .every() with negated predicate.
String? buildEveryReplacement(String collection, Expression predicate) {
  if (predicate is! FunctionExpression) return null;

  final body = predicate.body;
  final innerExpr = maybeGetSingleReturnExpression(body);
  if (innerExpr == null) return null;

  final paramList = predicate.parameters;
  if (paramList == null) return null;
  final params = paramList.toSource();
  final negated = negateExpression(innerExpr);
  return '$collection.every($params => $negated)';
}

/// Given a function body, returns the single return expression if there is one.
Expression? maybeGetSingleReturnExpression(FunctionBody body) {
  return switch (body) {
    ExpressionFunctionBody(:final expression) ||
    BlockFunctionBody(block: Block(statements: [ReturnStatement(:final expression?)])) => expression,
    _ => null,
  };
}

/// Negates an expression, handling double negation and parenthesization.
String negateExpression(Expression expr) {
  // Double negation removal: !x -> x
  if (expr is PrefixExpression && expr.operator.type == TokenType.BANG) {
    return expr.operand.toSource();
  }
  // Simple expressions don't need parentheses
  if (expr is SimpleIdentifier ||
      expr is PrefixedIdentifier ||
      expr is MethodInvocation ||
      expr is PropertyAccess ||
      expr is IndexExpression ||
      expr is ParenthesizedExpression ||
      expr is PrefixExpression ||
      expr is BooleanLiteral) {
    return '!${expr.toSource()}';
  }
  // Binary and other complex expressions need parentheses
  return '!(${expr.toSource()})';
}
