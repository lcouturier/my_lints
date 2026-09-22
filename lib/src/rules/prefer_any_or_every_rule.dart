import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferAnyRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_any',
    'Use .{0}() instead of .where().{1}.',
    correctionMessage: 'Replace with .{0}() for better readability and performance.',
  );

  PreferAnyRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferAnyRule rule;

  _Visitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      propertyName: SimpleIdentifier(name: final property && ('isEmpty' || 'isNotEmpty')),
      target: MethodInvocation(
        target: Expression(staticType: final targetType?),
        methodName: SimpleIdentifier(name: 'where'),
        argumentList: ArgumentList(:final arguments),
      ),
    ) when iterableChecker.isAssignableFromType(targetType) && arguments.length == 1) {
      final isNotEmpty = property == 'isNotEmpty';
      rule.reportAtNode(node, arguments: [isNotEmpty ? 'any' : '!any', property]);
    }
  }
}
