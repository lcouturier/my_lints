import 'package:analyzer/dart/ast/ast.dart';

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

Set<String> equatablePropsFields(ListLiteral propsList) =>
    propsList.elements.whereType<SimpleIdentifier>().map((identifier) => identifier.name).toSet();
