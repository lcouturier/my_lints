import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferFirstRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_first_over_index',
    "Use '.first' instead of accessing the first element by index.",
    correctionMessage: "Replace with '.first'.",
  );

  PreferFirstRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

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
    if (node case MethodInvocation(
      target: Expression(staticType: final targetType?),
      methodName: SimpleIdentifier(name: 'elementAt'),
      argumentList: ArgumentList(arguments: [IntegerLiteral(value: 0)]),
    ) when (iterableChecker.isAssignableFromType(targetType))) {
      rule.reportAtNode(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.isFirstElementAccess) {
      rule.reportAtNode(node);
    }
    super.visitIndexExpression(node);
  }
}

extension on IndexExpression {
  bool get isFirstElementAccess {
    if (this case IndexExpression(
      target: Expression(staticType: final targetType?),
      index: IntegerLiteral(value: 0),
    ) when (iterableChecker.isAssignableFromType(targetType))) {
      return true;
    }
    return false;
  }
}
