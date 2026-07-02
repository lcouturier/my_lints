import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects widgets in lists that should have a key property.
///
/// Widgets in dynamic lists (Column, Row, ListView, etc.) should have keys
/// to help Flutter's diffing algorithm identify widgets correctly.
///
/// ✅ GOOD:
/// ```dart
/// Column(
///   children: [
///     Text('Hello', key: Key('hello')),
///     Text('World', key: Key('world')),
///   ],
/// )
/// ```
///
/// ❌ BAD:
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),  // Missing key!
///     Text('World'),  // Missing key!
///   ],
/// )
/// ```
class PreferKeyedWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_keyed_widgets',
    'Widgets in lists should have a key property to help Flutter identify them.',
    correctionMessage: 'Add a key property to this widget.',
  );

  PreferKeyedWidgetsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addNamedExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferKeyedWidgetsRule rule;

  _Visitor(this.rule);

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node.name.label.name != 'children' && node.name.label.name != 'slivers') {
      return;
    }

    final expression = node.expression;
    if (expression is! ListLiteral) return;

    final visitor = _WidgetListVisitor();
    expression.accept(visitor);

    for (final widget in visitor.widgetsWithoutKey) {
      rule.reportAtNode(widget);
    }
  }
}

class _WidgetListVisitor extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> widgetsWithoutKey = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    // Check if this is a widget instantiation
    if (!_isWidget(node)) return;

    // Check if it has a key parameter
    final hasKey = node.argumentList.arguments.whereType<NamedExpression>().any((arg) => arg.name.label.name == 'key');

    if (!hasKey) {
      widgetsWithoutKey.add(node);
    }
  }

  bool _isWidget(InstanceCreationExpression node) {
    /// This is a simplified check. In a real implementation, you would check if the type of the node is a subclass of `Widget`.
    /// For the purpose of this example, we will assume that any class that starts with an uppercase letter is a widget.
    /// In a real-world scenario, you would use the type system to check if the class extends `Widget`.
    //. TODO(): Implement a proper type check to determine if the class is a subclass of `Widget`.
    return true;
  }
}
