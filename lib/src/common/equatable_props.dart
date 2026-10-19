import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

ListLiteral? equatablePropsList(MethodDeclaration method) {
  return switch (method.body) {
    ExpressionFunctionBody(expression: final ListLiteral items) => items,
    ExpressionFunctionBody(
      expression: CascadeExpression(
        target: PropertyAccess(propertyName: SimpleIdentifier(name: 'props'), realTarget: SuperExpression()),
        cascadeSections: [
          MethodInvocation(
            methodName: SimpleIdentifier(name: 'addAll'),
            argumentList: ArgumentList(arguments: [final ListLiteral items]),
          ),
        ],
      ),
    ) =>
      items,
    _ => null,
  };
}

Set<String> equatablePropsFields(ListLiteral propsList) {
  return {
    ...propsList.elements.whereType<SimpleIdentifier>().map((identifier) => identifier.name).toSet(),
    ...propsList.elements.whereType<BinaryExpression>().map((expression) {
      if (expression.leftOperand is SimpleIdentifier && expression.operator.type == TokenType.QUESTION_QUESTION) {
        return (expression.leftOperand as SimpleIdentifier).name;
      }
      return '';
    }).toSet(),
  };
}
