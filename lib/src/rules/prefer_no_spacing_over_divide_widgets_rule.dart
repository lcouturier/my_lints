import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferNoSpacingOverDivideWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_no_spacing_over_divide_widgets',
    'Prefer no spacing over divide widgets.',
    correctionMessage: 'Remove spacing over divide widgets.',
  );

  PreferNoSpacingOverDivideWidgetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferNoSpacingOverDivideWidgetsRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'divideWidgets'),
      argumentList: ArgumentList(
        arguments: [
          InstanceCreationExpression(
            keyword: Token(lexeme: 'const'),
            constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'SizedBox'))),
            argumentList: ArgumentList(
              arguments: [NamedExpression(name: Label(label: SimpleIdentifier(name: 'height')))],
            ),
          ),
        ],
      ),
    )) {
      rule.reportAtNode(node);
    }
    super.visitMethodInvocation(node);
  }
}
