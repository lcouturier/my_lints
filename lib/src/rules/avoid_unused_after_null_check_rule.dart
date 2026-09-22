import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidUnusedAfterNullCheckRule extends AnalysisRule {
  AvoidUnusedAfterNullCheckRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'avoid_unused_after_null_check',
    'The variable {0} is null-checked in a condition but never referenced inside the guarded block.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final AvoidUnusedAfterNullCheckRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    final condition = node.expression;
    if (condition case BinaryExpression(
      leftOperand: SimpleIdentifier(:final name),
      operator: Token(type: TokenType.BANG_EQ),
      rightOperand: NullLiteral(),
    )) {
      bool found = false;
      node.thenStatement.visitChildren(_IdentifierFinder(name: name, onFound: () => found = true));
      if (!found) {
        rule.reportAtNode(condition, arguments: [name]);
      }
    }

    super.visitIfStatement(node);
  }
}

class _IdentifierFinder extends RecursiveAstVisitor<void> {
  _IdentifierFinder({required this.name, required this.onFound});

  final String name;
  final void Function() onFound;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == name) onFound();
    super.visitSimpleIdentifier(node);
  }
}
