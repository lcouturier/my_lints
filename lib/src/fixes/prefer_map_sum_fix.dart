import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferMapSumFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'my_lints.fix.preferMapSum',
    DartFixKindPriority.standard,
    'Replace fold with map and sum',
  );

  PreferMapSumFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = node;
    final MethodInvocation invocation;
    if (targetNode is MethodInvocation) {
      invocation = targetNode;
    } else if (targetNode is SimpleIdentifier) {
      final ancestor = targetNode.thisOrAncestorOfType<MethodInvocation>();
      if (ancestor == null || ancestor.methodName != targetNode) return;
      invocation = ancestor;
    } else {
      return;
    }

    if (invocation case MethodInvocation(
      methodName: SimpleIdentifier(element: MethodElement(name: 'fold', library: LibraryElement(isDartCore: true))),
      :final target?,
      argumentList: ArgumentList(arguments: [final initialValue, final callback]),
    )) {
      final initial = initialValue.unParenthesized;
      if (initial is! IntegerLiteral || initial.value != 0) return;

      final function = callback.unParenthesized;
      if (function is! FunctionExpression) return;
      final body = function.body;
      if (body is! ExpressionFunctionBody) return;
      final parameters = function.parameters?.parameters;
      if (parameters == null || parameters.length != 2) return;

      final accumulator = parameters.first.declaredFragment?.element;
      if (accumulator == null || !accumulator.type.isDartCoreInt) return;

      final expression = body.expression.unParenthesized;
      if (expression is! BinaryExpression || expression.operator.type != TokenType.PLUS) return;
      final left = expression.leftOperand.unParenthesized;
      final right = expression.rightOperand;
      if (left is! SimpleIdentifier || left.element != accumulator || right.staticType?.isDartCoreInt != true) return;

      final accumulatorReferences = _AccumulatorVisitor(accumulator);
      right.accept(accumulatorReferences);
      if (accumulatorReferences.found) return;

      final replacement = '${target.toSource()}.map((${parameters[1].toSource()}) => ${right.toSource()}).sum';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(invocation), replacement);
      });
    }
  }
}

class _AccumulatorVisitor extends RecursiveAstVisitor<void> {
  final FormalParameterElement accumulator;
  bool found = false;

  _AccumulatorVisitor(this.accumulator);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element == accumulator) found = true;
    super.visitSimpleIdentifier(node);
  }
}
