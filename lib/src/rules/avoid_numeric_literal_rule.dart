// ignore_for_file: deprecated_member_use

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNumericLiteralsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_numeric_literal',
    'Avoid numeric literal',
    correctionMessage: 'Avoid numeric literal',
  );

  AvoidNumericLiteralsRule() : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addIntegerLiteral(this, visitor)
      ..addDoubleLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNumericLiteralsRule rule;

  _Visitor(this.rule);

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    if (_shouldIgnore(node)) return;
    rule.reportAtNode(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    if (_shouldIgnore(node)) return;
    rule.reportAtNode(node);
  }

  bool _isMinusOne(Expression node) {
    final parent = node.parent;
    return parent is PrefixExpression && parent.operator.lexeme == '-' && node is IntegerLiteral && node.value == 1;
  }

  bool _shouldIgnore(Expression node) {
    if (_isMinusOne(node)) return true;
    if (node.parent is IndexExpression) return true;

    // Remonter l'arbre une seule fois pour les vérifications de contexte
    AstNode? current = node.parent;
    while (current != null) {
      if (current is VariableDeclarationList && current.isConst) return true;
      if (current is EnumConstantArguments) return true;
      if (current is InstanceCreationExpression) {
        if (current.isConst) return true;
        final typeName = current.staticType?.getDisplayString(withNullability: false);
        if (typeName == 'DateTime' || typeName == 'Duration') return true;
      }
      current = current.parent;
    }

    return false;
  }
}
