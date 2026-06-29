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

      final body = callback.body;
      if (body is! ExpressionFunctionBody) return;
      final expression = body.expression;
      if (expression case BinaryExpression(
        :final leftOperand,
        :final rightOperand,
        operator: Token(type: TokenType.BANG_EQ),
      )) {
        if (_matches(leftOperand, rightOperand, callback.parameters?.parameters.first.name?.lexeme)) {
          rule.reportAtNode(node);
        }
      }
    }
  }

  bool _matches(Expression identifier, Expression other, String? parameter) {
    return identifier is SimpleIdentifier && identifier.name == parameter && other is NullLiteral;
  }
}
