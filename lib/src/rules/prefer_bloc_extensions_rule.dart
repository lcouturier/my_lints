import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

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
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferBlocExtensionsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node
        case MethodInvocation(
          methodName: SimpleIdentifier(name: 'of'),
          realTarget: SimpleIdentifier(name: 'BlocProvider'),
          :final argumentList,
        )
        when argumentList.arguments.any(
          (e) => e is NamedExpression && e.name.label.name == 'listen' && e.expression is BooleanLiteral,
        )) {
      rule.reportAtNode(node);
    }

    super.visitMethodInvocation(node);
  }
}
