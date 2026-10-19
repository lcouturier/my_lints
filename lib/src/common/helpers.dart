import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:my_lints/src/common/extensions.dart';

String? getContextName(AstNode node) {
  final executable = node.thisOrAncestorMatching(
    (ancestor) => ancestor is MethodDeclaration || ancestor is FunctionDeclaration,
  );
  if (executable == null) return null;

  final shadowedNames = <String>{};
  AstNode? ancestor = node.parent;
  while (ancestor != null && ancestor != executable) {
    if (ancestor is FunctionExpression) {
      final contextName = _buildContextName(ancestor.parameters?.parameters, shadowedNames);
      if (contextName != null) return contextName;
      shadowedNames.addAll(_parameterNames(ancestor.parameters?.parameters));
    }
    ancestor = ancestor.parent;
  }

  final parameters = switch (executable) {
    final MethodDeclaration method => method.parameters?.parameters,
    final FunctionDeclaration function => function.functionExpression.parameters?.parameters,
    _ => null,
  };

  return _buildContextName(parameters, shadowedNames);
}

String? _buildContextName(List<FormalParameter>? parameters, Set<String> shadowedNames) {
  for (final parameter in parameters ?? const <FormalParameter>[]) {
    final unwrapped = parameter.unWrapped;
    final name = unwrapped.name?.lexeme;
    if (name != null && !shadowedNames.contains(name) && unwrapped.isBuildContext) return name;
  }

  return null;
}

Iterable<String> _parameterNames(List<FormalParameter>? parameters) sync* {
  for (final parameter in parameters ?? const <FormalParameter>[]) {
    final name = parameter.unWrapped.name?.lexeme;
    if (name != null) yield name;
  }
}
