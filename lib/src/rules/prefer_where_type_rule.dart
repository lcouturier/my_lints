import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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
        rule.reportAtNode(node);
      }
    }
  }
}
