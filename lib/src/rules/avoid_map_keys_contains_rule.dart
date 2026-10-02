import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// Avoid using `keys.contains` for map key checks. Use `map.containsKey` instead for better performance.
/// Example:
/// ```dart
/// // LINT
/// if (myMap.keys.contains('key')) { ... }
///
/// // OK
/// if (myMap.containsKey('key')) { ... }
/// ```
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
    if (node case MethodInvocation(
      target: final target,
      methodName: SimpleIdentifier(name: 'contains'),
      argumentList: ArgumentList(arguments: [_]),
    )) {
      final mapTarget = switch (target) {
        PrefixedIdentifier(identifier: SimpleIdentifier(name: 'keys'), :final prefix) => prefix,
        PropertyAccess(propertyName: SimpleIdentifier(name: 'keys'), :final target) => target,
        _ => null,
      };
      if (mapTarget?.staticType != null && _isMap(mapTarget!.staticType!)) {
        rule.reportAtNode(node);
      }
    }
  }

  // ignore: unused_element
  bool _isMap(DartType type) {
    return type is InterfaceType && type.isDartCoreMap;
  }
}
