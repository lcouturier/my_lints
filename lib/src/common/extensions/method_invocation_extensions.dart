import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';

extension MethodInvocationExtensions on MethodInvocation {
  bool get isMapWithCast {
    final args = argumentList.arguments;
    if (args.length != 1) return false;
    final arg = args.first;
    if (arg is! FunctionExpression) return false;
    final body = arg.body;
    if (body is! ExpressionFunctionBody) return false;
    return body.expression is AsExpression;
  }

  /// Returns the type argument of the `where` method if it is a `where((x) => x is T)` call, otherwise returns null.
  DartType? get whereType {
    final arguments = argumentList.arguments;
    if (arguments.length != 1 || arguments.first is! FunctionExpression) {
      return null;
    }

    final callback = arguments.first as FunctionExpression;
    final body = callback.body;
    if (body is! ExpressionFunctionBody || body.expression is! IsExpression) {
      return null;
    }

    final expression = body.expression as IsExpression;
    if (expression.notOperator != null || expression.type is! NamedType) {
      return null;
    }

    return (expression.type as NamedType).type;
  }
}
