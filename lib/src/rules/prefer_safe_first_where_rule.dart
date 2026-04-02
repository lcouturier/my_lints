import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that detects when a parameter's field or setter is reassigned.
class PreferSafeFirstWhereRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_safe_first_where',
    'firstWhere(), lastWhere() and singleWhere() find the first or only element matching a condition, respectively. Both methods throw a StateError if no element matches, and singleWhere() throws an error if more than one element matches.',
    correctionMessage: 'Use the optional orElse parameter to provide a default if no element matches.',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferSafeFirstWhereRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const _methods = ['firstWhere', 'singleWhere', 'lastWhere'];

  _Visitor(this.rule);

  final PreferSafeFirstWhereRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node
        case MethodInvocation(
          target: final target?,
          methodName: SimpleIdentifier(name: final methodName),
          argumentList: ArgumentList(arguments: final args),
        )
        when !args.any((arg) => arg is NamedExpression && arg.name.label.name == 'orElse') &&
            _methods.contains(methodName) &&
            _isIterable(target)) {
      rule.reportAtNode(node);
    }
  }

  bool _isIterable(Expression target) {
    final type = target.staticType;
    if (type == null) return false;

    if (type.isDartCoreIterable) return true;
    return (type as InterfaceType).allSupertypes.any((t) => t.isDartCoreIterable);
  }
}
