import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Detects [GestureDetector] widgets without any event handlers.
///
/// A [GestureDetector] without `onTap`, `onLongPress`, etc. is useless
/// and should either have handlers added or be removed entirely.
///
/// ✅ GOOD:
/// ```dart
/// GestureDetector(onTap: () => print('tapped'), child: Text('Press'))
/// ```
///
/// ❌ BAD:
/// ```dart
/// GestureDetector(child: Text('Press'))  // No handlers!
/// ```
class AvoidUnnecessaryGestureDetectorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unnecessary_gesture_detector',
    'Try passing an event handler (e.g. onTap) or removing this widget.',
    correctionMessage: 'Add an event handler or remove this widget.',
  );

  AvoidUnnecessaryGestureDetectorRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnnecessaryGestureDetectorRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(element: ClassElement(name: 'GestureDetector'))),
      :final argumentList,
    ) when !argumentList.arguments.whereType<NamedExpression>().any((e) => e.name.label.name.startsWith('on'))) {
      rule.reportAtNode(node);
    }
  }
}
