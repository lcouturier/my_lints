import 'package:analyzer/dart/ast/ast.dart';

extension FunctionBodyExtensions on FunctionBody {
  // Returns the expression from a function body.
  Expression? get expression => switch (this) {
    BlockFunctionBody(:final block) => block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
    ExpressionFunctionBody(:final expression) => expression,
    _ => null,
  };

  // Checks if a function body has a return statement.
  bool get hasReturnStatement {
    return switch (this) {
      final BlockFunctionBody b => b.block.statements.any((e) => e is ReturnStatement),
      ExpressionFunctionBody _ => true,
      _ => false,
    };
  }

  // Checks if a function body returns `this`.
  bool get hasReturnThis {
    return switch (this) {
      final BlockFunctionBody b => b.block.statements.whereType<ReturnStatement>().first.expression is ThisExpression,
      final ExpressionFunctionBody e => e.expression is ThisExpression,
      _ => false,
    };
  }
}
