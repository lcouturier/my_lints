import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidMountedInSetStateRule extends AnalysisRule {
  static LintCode code = const LintCode('avoid_mounted_in_set_state', 'Never use mounted in a setState callback.');

  AvoidMountedInSetStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    //registry.addClassDeclaration(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidMountedInSetStateRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'setState') return;

    final enclosingClass = node.thisOrAncestorOfType<ClassDeclaration>();
    if (enclosingClass == null || !enclosingClass.isFlutterStateClass) return;

    final arg = node.argumentList.arguments.firstOrNull;
    if (arg is! FunctionExpression) return;

    final body = arg.body;
    if (body is! BlockFunctionBody) return;

    bool hasMounted = false;
    body.block.visitChildren(_MountedFinder((_) => hasMounted = true));

    if (hasMounted) {
      rule.reportAtNode(node);
    }
  }
}

class _MountedFinder extends RecursiveAstVisitor<void> {
  final void Function(SimpleIdentifier) onFound;

  _MountedFinder(this.onFound);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'mounted') {
      onFound(node);
    }
  }
}
