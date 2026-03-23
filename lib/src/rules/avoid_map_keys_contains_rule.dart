import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidMapKeysContainsRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'avoid_map_keys_contains',
    'Avoid using keys.contains for map key checks.',
    correctionMessage: 'Use map.containsKey instead for better performance.',
    severity: DiagnosticSeverity.WARNING,
  );
  AvoidMapKeysContainsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidMapKeysContainsRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'contains') return;
    if (node.argumentList.arguments.length != 1) return;

    final target = node.target;

    if (target case PrefixedIdentifier(
      identifier: SimpleIdentifier(name: 'keys'),
      prefix: SimpleIdentifier(name: 'map'),
    )) {
      rule.reportAtNode(node);
    }
    if (target case PropertyAccess(
      propertyName: SimpleIdentifier(name: 'keys'),
      target: SimpleIdentifier(name: 'map'),
    )) {
      rule.reportAtNode(node);
    }
  }
}
