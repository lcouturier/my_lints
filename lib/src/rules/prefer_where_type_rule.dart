// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferWhereTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_where_type',
    'Prefer using whereType<T>() instead of where((e) => e != null)',
  );

  PreferWhereTypeRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferWhereTypeRule rule;

  _Visitor(this.rule);

  bool _isMapWithAsCast(MethodInvocation mapInvocation) {
    final args = mapInvocation.argumentList.arguments;
    if (args.length != 1) return false;
    final arg = args.first;
    if (arg is! FunctionExpression) return false;
    final body = arg.body;
    if (body is! ExpressionFunctionBody) return false;
    return body.expression is AsExpression;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'where'),
      argumentList: ArgumentList(arguments: final arguments),
    ) when arguments.length == 1) {
      final callback = arguments.first;
      if (callback is! FunctionExpression) return;
      if (callback.parameters != null && callback.parameters!.parameters.length != 1) return;

      final parameter = callback.parameters?.parameters.first.name?.lexeme;

      final body = callback.body;
      if (body is! ExpressionFunctionBody) return;
      final expression = body.expression;

      /// where((e) => e != null)
      if (expression case BinaryExpression(
        leftOperand: SimpleIdentifier(:final name),
        operator: Token(type: TokenType.BANG_EQ),
        rightOperand: NullLiteral(),
      ) when name == parameter) {
        rule.reportAtNode(node);
      }

      /// where((e) => e is String)
      if (expression case IsExpression(
        expression: SimpleIdentifier(:final name),
        isOperator: Token(type: TokenType.IS),
      ) when name == parameter) {
        final parent = node.parent;
        if (parent is MethodInvocation && parent.target == node) {
          final parentMethod = parent.methodName.name;

          // items.where((x) => x is String).cast<String>();
          if (parentMethod == 'cast') {
            rule.reportAtNode(parent);
            return;
          }

          // items.where((x) => x is String).map((x) => x as String);
          if (parentMethod == 'map' && parent.isMapWithCast) {
            rule.reportAtNode(parent);
            return;
          }
        }
        rule.reportAtNode(node);
      }
    }
  }
}
