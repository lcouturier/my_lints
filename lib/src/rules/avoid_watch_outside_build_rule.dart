import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidWatchOutsideBuildRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_watch_outside_build',
    'Watching a stream outside of a build method can lead to memory leaks.',
  );

  AvoidWatchOutsideBuildRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);

    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidWatchOutsideBuildRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    for (var element in node.members.whereType<MethodDeclaration>()) {
      final visitor = _WatchVisitor();
      element.body.accept(visitor);
      if (visitor.matches.isNotEmpty) {
        for (var item in visitor.matches) {
          rule.reportAtNode(item);
        }
      }
    }
  }
}

class _WatchVisitor extends RecursiveAstVisitor<void> {
  _WatchVisitor() : matches = [];

  List<AstNode> matches;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'watch') return;

    final target = node.target;
    if (target == null) return;

    if (target.staticType?.getDisplayString(withNullability: false) != 'BuildContext') return;

    final enclosingMethod = node.thisOrAncestorOfType<MethodDeclaration>();
    if (enclosingMethod?.name.lexeme == 'build') return;

    matches.add(node);

    super.visitMethodInvocation(node);
  }
}
