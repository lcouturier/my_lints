import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferFirstRule extends AnalysisRule {
  static final LintCode code = LintCode('prefer_first_rule', 'Prefer using first instead of where().first');

  PreferFirstRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIndexExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferFirstRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    if (isIterableOrSubclass(node.realTarget?.staticType) && node.methodName.name == 'elementAt') {
      final arg = node.argumentList.arguments.first;

      if (arg is IntegerLiteral && arg.value == 0) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (isListOrSubclass(node.realTarget.staticType)) {
      final index = node.index;

      if (index is IntegerLiteral && index.value == 0) {
        rule.reportAtNode(node);
      }
    }
  }
}
