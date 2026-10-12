// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

const _edgeInsetsTypeChecker = TypeChecker.fromName('EdgeInsets', packageName: 'flutter');

/// A rule that prefers symmetric insets when opposing values are equal.
///
/// In widget methods, this rule reports `EdgeInsets.only` and `EdgeInsets.fromLTRB`
/// when their opposing horizontal or vertical values are equal and the other
/// axis is omitted or zero.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// const EdgeInsets.only(left: 8, right: 8);
/// ```
///
/// ✅ Good:
/// ```dart
/// const EdgeInsets.symmetric(horizontal: 8);
/// ```
class EdgeInsetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_edge_insets_symmetric',
    'Prefer using EdgeInsets.symmetric when opposing EdgeInsets values are equal.',
    correctionMessage: 'Use EdgeInsets.symmetric to express the equal opposing values.',
  );

  EdgeInsetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
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
    if (node case ClassDeclaration(isFlutterWidget: true)) {
      for (var element in node.members.whereType<MethodDeclaration>()) {
        final visitor = _EdgeInsetsOnlyVisitor();
        element.body.accept(visitor);
        if (visitor.matches.isNotEmpty) {
          for (var item in visitor.matches) {
            rule.reportAtNode(item);
          }
        }
      }
    }
  }
}

class _EdgeInsetsOnlyVisitor extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> matches = [];

  _EdgeInsetsOnlyVisitor();

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(name: Identifier(:final name), type: NamedType(:final element?)),
    ) when ((name == 'only' || name == 'fromLTRB') && _edgeInsetsTypeChecker.isExactly(element))) {
      final handle = switch (name) {
        'only' => () => _handleEdgeInsetsOnly(node),
        'fromLTRB' => () => _handleEdgeInsetsFromLTRB(node),
        _ => null,
      };
      handle?.call();
    }

    super.visitInstanceCreationExpression(node);
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
    final values = node.argumentList.arguments.map(_extractNumeric).toList();
    if (values.length != 4) return;

    final left = values[0];
    final top = values[1];
    final right = values[2];
    final bottom = values[3];

    if (left == null || right == null || top == null || bottom == null) return;
    final sameHorizontal = left == right;
    final sameVertical = top == bottom;

    if (sameHorizontal && sameVertical) {
      matches.add(node);
    } else if (sameHorizontal && top == 0 && bottom == 0) {
      matches.add(node);
    } else if (sameVertical && left == 0 && right == 0) {
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
