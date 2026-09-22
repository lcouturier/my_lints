import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class DoNotCallToListAfterDivideWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'do_not_call_to_list_after_divide_widgets',
    'Do not call toList() after divideWidgets method.',
  );

  DoNotCallToListAfterDivideWidgetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _DoNotCallToListAfterDivideWidgetsVisitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _DoNotCallToListAfterDivideWidgetsVisitor extends RecursiveAstVisitor<void> {
  final DoNotCallToListAfterDivideWidgetsRule rule;

  _DoNotCallToListAfterDivideWidgetsVisitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'toList'),
      target: MethodInvocation(methodName: SimpleIdentifier(name: 'divideWidgets')),
    )) {
      rule.reportAtNode(node.methodName);
    }
    super.visitMethodInvocation(node);
  }
}
