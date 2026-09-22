import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferSpacingOverDivideWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_spacing_over_divide_widgets',
    'Prefer spacing property on column instead of divideWidgets meethod.',
    correctionMessage: 'Use spacing property instead of divideWidgets method.',
  );

  PreferSpacingOverDivideWidgetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferSpacingOverDivideWidgetsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    super.visitClassDeclaration(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'Column'))),
      argumentList: ArgumentList(
        arguments: [
          ...,
          NamedExpression(
            name: Label(label: SimpleIdentifier(name: 'children')),
            expression: MethodInvocation(
              methodName: SimpleIdentifier(name: 'divideWidgets'),
              target: final target,
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
            ),
          ),
        ],
      ),
    )) {
      if (target is ListLiteral &&
          target.elements.whereType<InstanceCreationExpression>().every(
            (e) => e.constructorName.type.name.lexeme != 'IgnoreDividerInsertion',
          )) {
        rule.reportAtNode(node);
        return;
      }

      rule.reportAtNode(node);
    }
    super.visitInstanceCreationExpression(node);
  }
}
