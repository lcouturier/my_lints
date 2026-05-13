// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class EdgeInsetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_edge_insets_symmetric',
    'Prefer using EdgeInsets.symmetric instead of EdgeInsets.only when left and right (or top and bottom) values are the same.',
    correctionMessage: 'Use EdgeInsets.symmetric instead of EdgeInsets.only.',
  );

  EdgeInsetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    // registry.addInstanceCreationExpression(this, _Visitor(this));
    registry.addClassDeclaration(this, _Visitor(this));
  }

  @override
  DiagnosticCode get diagnosticCode => code;
}

class _Visitor extends SimpleAstVisitor<void> {
  final EdgeInsetsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    final visitor = _EdgeInsetsOnlyVisitor();

    for (var element in node.members.whereType<MethodDeclaration>()) {
      element.body.accept(visitor);
      if (visitor.matches.isNotEmpty) {
        for (var item in visitor.matches) {
          rule.reportAtNode(item);
        }
      }
    }

    super.visitClassDeclaration(node);
  }
}

class _EdgeInsetsOnlyVisitor extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> matches = [];

  _EdgeInsetsOnlyVisitor();

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: final typeName), name: final constructorName?),
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
    final top = args['top'];
    final right = args['right'];
    final bottom = args['bottom'];

    if (left != null && right != null && _sameNumericValue(left, right) && top == null && bottom == null) {
      matches.add(node);
    }

    if (top != null && bottom != null && _sameNumericValue(top, bottom) && left == null && right == null) {
      matches.add(node);
    }
  }

  void _handleEdgeInsetsFromLTRB(InstanceCreationExpression node) {
    final args = {for (final arg in node.argumentList.arguments.whereType<IntegerLiteral>().indexed) arg.$1: arg.$2};

    final left = args[0];
    final top = args[1];
    final right = args[2];
    final bottom = args[3];

    if (left == null || right == null || top == null || bottom == null) return;
    final sameHorizontal = (left.value == right.value);
    final sameVertical = (top.value == bottom.value);
    final allEqual = (left.value == top.value) && (top.value == right.value) && (right.value == bottom.value);

    if (allEqual) {
      matches.add(node);
    } else if (sameHorizontal && sameVertical) {
      matches.add(node);
    } else if (sameHorizontal && top.isZero && bottom.isZero) {
      matches.add(node);
    } else if (sameVertical && left.isZero && right.isZero) {
      matches.add(node);
    }
  }
}

bool _sameNumericValue(NamedExpression a, NamedExpression b) {
  final aVal = _extractNumeric(a.expression);
  final bVal = _extractNumeric(b.expression);

  if (aVal == null || bVal == null) return false;

  return aVal.toDouble() == bVal.toDouble();
}

num? _extractNumeric(Expression expr) {
  if (expr is IntegerLiteral) return expr.value;
  if (expr is DoubleLiteral) return expr.value;

  return null;
}

extension on Expression? {
  bool get isZero {
    return switch (this) {
      IntegerLiteral(:final value) => value == 0,
      DoubleLiteral(:final value) => value == 0.0,
      _ => false,
    };
  }
}
