import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';

String? getContextName(AstNode node) {
  final executable = node.thisOrAncestorMatching(
    (ancestor) => ancestor is MethodDeclaration || ancestor is FunctionDeclaration,
  );
  final parameters = switch (executable) {
    final MethodDeclaration method => method.parameters?.parameters,
    final FunctionDeclaration function => function.functionExpression.parameters?.parameters,
    _ => null,
  };

  for (final parameter in parameters ?? const <FormalParameter>[]) {
    final unwrapped = parameter.unWrapped;
    if (unwrapped.isBuildContext) return unwrapped.name?.lexeme;
  }

  return null;
}
