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
    final items = [
      () => node.thisOrAncestorOfType<VariableDeclarationList>()?.isConst ?? false,
      () => _isMinusOne(node),
      () => node.thisOrAncestorOfType<EnumConstantArguments>() != null,
      () => node.thisOrAncestorOfType<InstanceCreationExpression>()?.isConst ?? false,
      () => node.isInstanceCreationDateTime,
      () => node.isInstanceCreationDuration,
    ];

    return items.any((e) => e());
  }
}

extension on Expression {
  bool get isInstanceCreationDateTime {
    final instance = thisOrAncestorOfType<InstanceCreationExpression>();
    if (instance == null) return false;
    return instance.staticType?.element?.name == 'DateTime';
  }

  bool get isInstanceCreationDuration {
    final instance = thisOrAncestorOfType<InstanceCreationExpression>();
    if (instance == null) return false;
    return instance.staticType?.element?.name == 'Duration';
  }
}
