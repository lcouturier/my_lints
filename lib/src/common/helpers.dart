import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

mixin ContextName {
  (bool, String) getContextName(MethodDeclaration? Function() getMethod, FunctionDeclaration? Function() getFunction) {
    final method = getMethod();

    if (method != null) {
      final parameters = method.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');

      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    final function = getFunction();
    if (function != null) {
      final parameters = function.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');
      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    return (false, '');
  }
}
