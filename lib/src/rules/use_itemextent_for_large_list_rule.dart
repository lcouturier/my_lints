import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class UseItemextentForLargeListRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'use_itemextent_for_large_list',
    'Use itemExtent for large lists.',
    correctionMessage: 'Add itemExtent or prototypeItem to ListView.builder for better performance',
  );

  UseItemextentForLargeListRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final UseItemextentForLargeListRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    super.visitClassDeclaration(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(
        type: NamedType(name: Token(lexeme: 'ListView')),
        name: SimpleIdentifier(token: Token(lexeme: 'builder')),
      ),
      argumentList: ArgumentList(:final arguments),
    )) {
      final hasItemExtent = arguments.any((arg) => arg is NamedExpression && arg.name.label.name == 'itemExtent');
      final hasPrototypeItem = arguments.any((arg) => arg is NamedExpression && arg.name.label.name == 'prototypeItem');

      if (!(hasItemExtent || hasPrototypeItem)) {
        rule.reportAtNode(node);
      }
    }

    super.visitInstanceCreationExpression(node);
  }
}
