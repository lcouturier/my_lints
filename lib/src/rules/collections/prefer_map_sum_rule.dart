import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// A rule that suggests `map` and `sum` for integer summation folds.
///
/// It detects core iterable `fold` calls starting at zero whose expression
/// callback adds an integer expression to the accumulator without otherwise
/// using that accumulator. The `sum` getter requires an extension, such as
/// the one provided by `package:collection`.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// values.fold<int>(0, (total, value) => total + value.length);
/// ```
///
/// ✅ Good:
/// ```dart
/// // With import 'package:collection/collection.dart';
/// values.map((value) => value.length).sum;
/// ```
class PreferMapSumRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_map_sum',
    'Consider using map and sum instead of this integer summation fold.',
    correctionMessage: 'Use map followed by sum when an integer sum extension is available.',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferMapSumRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferMapSumRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'fold' || node.target == null) return;
    if (node.methodName.element?.library?.uri != Uri.parse('dart:core')) return;

    final arguments = node.argumentList.arguments;
    if (arguments.length != 2) return;
    final initialValue = arguments[0].unParenthesized;
    if (initialValue is! IntegerLiteral || initialValue.value != 0) return;

    final callback = arguments[1].unParenthesized;
    if (callback is! FunctionExpression || callback.body is! ExpressionFunctionBody) return;
    final parameters = callback.parameters?.parameters;
    if (parameters == null || parameters.length != 2) return;
    final accumulator = parameters.first.declaredFragment?.element;
    if (accumulator == null || !accumulator.type.isDartCoreInt) return;

    final expression = (callback.body as ExpressionFunctionBody).expression.unParenthesized;
    if (expression is! BinaryExpression || expression.operator.type != TokenType.PLUS) return;
    final left = expression.leftOperand.unParenthesized;
    final right = expression.rightOperand;
    if (left is! SimpleIdentifier || left.element != accumulator || right.staticType?.isDartCoreInt != true) return;

    final accumulatorReferences = _AccumulatorReferences(accumulator);
    right.accept(accumulatorReferences);
    if (accumulatorReferences.found) return;

    rule.reportAtNode(node.methodName);
  }
}

class _AccumulatorReferences extends RecursiveAstVisitor<void> {
  final FormalParameterElement accumulator;
  bool found = false;

  _AccumulatorReferences(this.accumulator);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element == accumulator) found = true;
    super.visitSimpleIdentifier(node);
  }
}
