import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidUnnecessaryBlockRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unnecessary_block',
    'Avoid unnecessary block.',
    correctionMessage: 'Remove the unnecessary block.',
  );

  AvoidUnnecessaryBlockRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addBlock(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidUnnecessaryBlockRule rule;

  _Visitor(this.rule);

  @override
  void visitBlock(Block node) {
    for (final statement in node.statements) {
      if (statement is Block) {
        rule.reportAtNode(statement);
      }
    }
    super.visitBlock(node);
  }
}
