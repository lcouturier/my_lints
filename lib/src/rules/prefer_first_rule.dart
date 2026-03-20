import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferFirstRule extends AnalysisRule {
  static const LintCode code = LintCode('prefer_first_over_index', 'prefer first over index 0');

  PreferFirstRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addIndexExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferFirstRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'elementAt') {
      final args = node.argumentList.arguments;
      if (args.isEmpty) return;

      final arg = args.first;

      if (arg is IntegerLiteral && arg.value == 0) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    final index = node.index;

    if (index is IntegerLiteral && index.value == 0) {
      rule.reportAtNode(node);
    }
  }
}
