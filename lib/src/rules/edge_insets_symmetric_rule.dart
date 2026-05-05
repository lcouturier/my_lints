// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class EdgeInsetsSymmetricRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_edge_insets_symmetric',
    'Prefer using EdgeInsets.symmetric instead of EdgeInsets.only when left and right (or top and bottom) values are the same.',
    correctionMessage: 'Use EdgeInsets.symmetric instead of EdgeInsets.only.',
  );

  EdgeInsetsSymmetricRule() : super(name: code.name, description: code.problemMessage);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }

  @override
  DiagnosticCode get diagnosticCode => code;
}

class _Visitor extends RecursiveAstVisitor<void> {
  final EdgeInsetsSymmetricRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: var typeName), name: var constructorName?),
    )) {
      if (typeName.lexeme == 'EdgeInsets' && constructorName.token.lexeme == 'only') {
        _handleEdgeInsetsOnly(node);
      }

      if (typeName.lexeme == 'EdgeInsets' && constructorName.token.lexeme == 'fromLTRB') {
        _handleEdgeInsetsFromLTRB(node);
      }
    }
  }

  void _handleEdgeInsetsOnly(InstanceCreationExpression node) {
    final args = {for (final arg in node.argumentList.arguments.whereType<NamedExpression>()) arg.name.label.name: arg};

    final left = args['left'];
    final right = args['right'];
    final top = args['top'];
    final bottom = args['bottom'];

    if (left != null && right != null && _isSameValue(left, right) && top == null && bottom == null) {
      rule.reportAtNode(node);
    }

    if (top != null && bottom != null && _isSameValue(top, bottom) && left == null && right == null) {
      rule.reportAtNode(node);
    }
  }

  void _handleEdgeInsetsFromLTRB(InstanceCreationExpression node) {
    final args = {for (final arg in node.argumentList.arguments.whereType<NamedExpression>()) arg.name.label.name: arg};

    final left = args['left'];
    final right = args['right'];
    final top = args['top'];
    final bottom = args['bottom'];

    final sameHorizontal = _isSameValue(left!, right!);
    final sameVertical = _isSameValue(top!, bottom!);
    final allEqual = _isSameValue(left, top) && _isSameValue(top, right) && _isSameValue(right, bottom);

    if (allEqual) {
      rule.reportAtNode(node);
    } else if (sameHorizontal && sameVertical) {
      rule.reportAtNode(node);
    } else if (sameHorizontal && top.isZero && bottom.isZero) {
      rule.reportAtNode(node);
    } else if (sameVertical && left.isZero && right.isZero) {
      rule.reportAtNode(node);
    }
  }
}

bool _isSameValue(NamedExpression a, NamedExpression b) {
  return a.expression.toSource() == b.expression.toSource();
}

extension on Expression? {
  bool get isZero => this != null && (this?.toSource() == '0' || this?.toSource() == '0.0');
}
