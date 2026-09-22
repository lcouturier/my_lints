// ignore_for_file: deprecated_member_use

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidMagicNumbersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_magic_numbers',
    'Avoid using numeric literals directly in code.',
    correctionMessage: 'Avoid using magic numbers. Consider defining them as constants with meaningful names.',
  );

  AvoidMagicNumbersRule() : super(name: code.name, description: code.problemMessage);

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
  final AvoidMagicNumbersRule rule;

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

  bool _isInsideAnnotation(Expression node) {
    return node.thisOrAncestorOfType<Annotation>() != null;
  }

  bool _isMinusOne(Expression node) {
    final parent = node.parent;
    return parent is PrefixExpression && parent.operator.lexeme == '-' && node is IntegerLiteral && node.value == 1;
  }

  bool _isAllowedNumber(Expression node) {
    if (node is IntegerLiteral) {
      return node.value == 0 || node.value == 1;
    }
    if (node is DoubleLiteral) {
      return node.value == 0.0 || node.value == 1.0;
    }
    return false;
  }

  bool _shouldIgnore(Expression node) {
    if (_isAllowedNumber(node)) return true;
    if (_isMinusOne(node)) return true;
    if (_isInsideAnnotation(node)) return true;
    if (node.parent is IndexExpression) return true;

    AstNode? current = node.parent;
    while (current != null) {
      if (current is VariableDeclarationList && current.isConst) return true;
      if (current is EnumConstantArguments) return true;
      if (current case InstanceCreationExpression(isConst: true)) {
        return true;
      }
      if (current case InstanceCreationExpression(
        constructorName: ConstructorName(type: NamedType(name: Token(:final lexeme))),
      ) when lexeme == 'Duration' || lexeme == 'DateTime') {
        return true;
      }

      current = current.parent;
    }

    return false;
  }
}
