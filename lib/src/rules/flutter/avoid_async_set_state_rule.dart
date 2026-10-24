import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that detects asynchronous callbacks passed to `setState`.
///
/// The callback passed to `setState` must update state synchronously. Complete
/// asynchronous work before calling `setState`.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// setState(() async {
///   await save();
///   value = 'saved';
/// });
/// ```
///
/// ✅ Good:
/// ```dart
/// await save();
/// if (!mounted) return;
/// setState(() {
///   value = 'saved';
/// });
/// ```
class AvoidAsyncSetStateRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_async_set_state',
    'Do not pass an async callback to setState.',
    correctionMessage: 'Complete asynchronous work before calling setState and keep its callback synchronous.',
  );

  AvoidAsyncSetStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidAsyncSetStateRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStatefulWidget) return;

    for (final method in node.members.whereType<MethodDeclaration>()) {
      method.body.accept(_SetStateVisitor(rule));
    }
  }
}

class _SetStateVisitor extends RecursiveAstVisitor<void> {
  final AvoidAsyncSetStateRule rule;

  _SetStateVisitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'setState'),
      argumentList: ArgumentList(arguments: [FunctionExpression(body: FunctionBody(isAsynchronous: true))]),
    )) {
      rule.reportAtNode(node);
    }

    super.visitMethodInvocation(node);
  }
}
