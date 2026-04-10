import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidEmptySetStateRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'avoid_empty_set_state',
    'Calling setState with an empty callback will still cause the widget to be re-rendered, but since it does not change the state, an empty callback is usually a sign of a bug.',
  );

  AvoidEmptySetStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidEmptySetStateRule rule;

  _Visitor(this.rule);
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

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
    if (node.methodName.name != 'setState') return;

    if (node.argumentList.arguments.isEmpty) return;
    final argument = node.argumentList.arguments.first;
    if (argument is! FunctionExpression) return;
    if (argument.body is! BlockFunctionBody) return;

    final body = argument.body as BlockFunctionBody;
    if (body.block.statements.isNotEmpty) return;

    matches.add(node);

    super.visitMethodInvocation(node);
  }
}
