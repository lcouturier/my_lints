import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class UnnecessaryToStringInInterpolationRule extends AnalysisRule {
  static const code = LintCode(
    'unnecessary_to_string_in_interpolation',
    'Unnecessary `toString()` call in string interpolation.',
    correctionMessage: 'Remove unnecessary `toString()` call.',
  );

  UnnecessaryToStringInInterpolationRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInterpolationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final UnnecessaryToStringInInterpolationRule rule;

  _Visitor(this.rule);

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    if (node.leftBracket.type != TokenType.STRING_INTERPOLATION_EXPRESSION) {
      return;
    }

    final expression = node.expression.unParenthesized;
    if (expression case MethodInvocation(
      methodName: SimpleIdentifier(name: 'toString'),
      argumentList: ArgumentList(arguments: []),
    )) {
      rule.reportAtNode(node);
      return;
    }
  }
}
