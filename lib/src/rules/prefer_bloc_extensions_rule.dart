import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/type_checker.dart';

class PreferBlocExtensionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_bloc_extensions',
    'Prefer using BLoC extensions for state and event access.',
    correctionMessage: 'Use BLoC extensions instead of direct property access.',
  );

  PreferBlocExtensionsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferBlocExtensionsRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'of'),
      realTarget: SimpleIdentifier(name: 'BlocProvider'),
      :final argumentList,
    )) {
      final (:found, value: named) = argumentList.arguments.firstWhereOrNot((e) => e.toString().startsWith('listen:'));
      if (found) {
        if (named is! NamedExpression) return;
        if (named.name.label.name != 'listen') return;
        if (named.expression is! BooleanLiteral) return;
      }
      rule.reportAtNode(node);
    }

    super.visitMethodInvocation(node);
  }
}
