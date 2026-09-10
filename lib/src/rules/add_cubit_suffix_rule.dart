import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/rule_visitor_extensions.dart';

class AddCubitSuffixRule extends AnalysisRule {
  static LintCode code = const LintCode('add_cubit_suffix_rule', 'Consider add cubit suffix.');

  AddCubitSuffixRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addCubitClass(this, visitor);
  }
}

class _Visitor extends CustomAstVisitor {
  final AddCubitSuffixRule rule;

  _Visitor(this.rule);

  @override
  void visitCubitClass(ClassDeclaration node) {
    if (node.name.lexeme.endsWith('Cubit')) return;

    rule.reportAtToken(node.name);
  }
}
