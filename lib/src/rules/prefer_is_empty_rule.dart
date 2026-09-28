import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferIsEmptyRule extends AnalysisRule {
  PreferIsEmptyRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'prefer_is_empty',
    'Prefer using `isEmpty`/`isNotEmpty` instead of comparing `length` to `0`.',
    correctionMessage: 'Replace `.length == 0` with `.isEmpty` and `.length != 0` with `.isNotEmpty`.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferIsEmptyRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (!node.isEmptinessComparison) return;

    rule.reportAtNode(node);
  }
}
