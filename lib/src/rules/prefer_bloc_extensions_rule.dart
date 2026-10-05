import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// Prefer using BLoC extensions for state and event access instead of direct property access.
/// This rule encourages the use of BLoC extensions like `context.read<MyBloc>()` and `context.watch<MyBloc>()` instead of directly accessing the `state` or `event` properties of the BLoC.
/// Example:
/// ```dart
/// // Avoid:
/// BlocProvider.of<MyBloc>(context).update();
///
/// // Prefer:
/// context.read<MyBloc>().update();
/// ```
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
    if (!node.isFlutterWidget) return;

    for (var element in node.members.whereType<MethodDeclaration>()) {
      final visitor = _BlocProvider();
      element.body.accept(visitor);
      if (visitor.matches.isNotEmpty) {
        for (var item in visitor.matches) {
          rule.reportAtNode(item);
        }
      }
    }
  }
}

class _BlocProvider extends RecursiveAstVisitor<void> {
  _BlocProvider() : matches = [];

  List<AstNode> matches;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: SimpleIdentifier(name: 'of'),
      realTarget: SimpleIdentifier(name: 'BlocProvider'),
    )) {
      matches.add(node);
    }

    super.visitMethodInvocation(node);
  }
}
