import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// Never use mounted in a setState callback.
///
/// Instead, use WidgetsBinding.instance.addPostFrameCallback or similar.
class AvoidMountedInSetStateRule extends AnalysisRule {
  static LintCode code = const LintCode('avoid_mounted_in_set_state', 'Never use mounted in a setState callback.');

  AvoidMountedInSetStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidMountedInSetStateRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterWidget) return;

    for (var element in node.members.whereType<MethodDeclaration>()) {
      final visitor = _SetStateVisitor();
      element.body.accept(visitor);
      if (visitor.matches.isNotEmpty) {
        for (var item in visitor.matches) {
          rule.reportAtNode(item);
        }
      }
    }
  }
}

class _SetStateVisitor extends RecursiveAstVisitor<void> {
  _SetStateVisitor() : matches = [];

  List<AstNode> matches;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(methodName: SimpleIdentifier(name: 'setState'))) {
      bool hasMounted = false;
      (node.argumentList.arguments.first as FunctionExpression).body.visitChildren(
        _MountedFinder(() => hasMounted = true),
      );

      if (hasMounted) {
        matches.add(node);
      }
    }

    super.visitMethodInvocation(node);
  }
}

class _MountedFinder extends RecursiveAstVisitor<void> {
  final void Function() onFound;

  _MountedFinder(this.onFound);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'mounted') {
      onFound();
    }
  }
}
