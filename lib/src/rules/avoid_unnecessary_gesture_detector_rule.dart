import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

class AvoidUnnecessaryGestureDetectorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unnecessary_gesture_detector',
    'Try passing an event handler (e.g. onTap) or removing this widget.',
  );

  AvoidUnnecessaryGestureDetectorRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
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
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'GestureDetector'))),
      :final argumentList,
    ) when !argumentList.arguments.whereType<NamedExpression>().any((e) => e.name.label.name.startsWith('on'))) {
      rule.reportAtNode(node);
    }
  }
}
