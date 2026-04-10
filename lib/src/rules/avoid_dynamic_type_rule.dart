import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidDynamicTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_dynamic_type',
    'Using dynamic is considered unsafe since it can easily result in runtime errors.',
    correctionMessage: 'Try replacing it with a different type.',
  );

  AvoidDynamicTypeRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addNamedType(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidDynamicTypeRule rule;

  @override
  void visitNamedType(NamedType node) {
    if (node case NamedType(name: Token(lexeme: 'dynamic'))) {
      rule.reportAtNode(node);
    }
  }
}
