import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that prefers `BlocProvider.of` calls to BuildContext BLoC extensions.
///
/// In Flutter widget classes, this rule reports calls to `BlocProvider.of`.
/// Use `context.read` or `context.watch` to access the provided BLoC.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     BlocProvider.of<MyBloc>(context).update();
///     return const SizedBox();
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     context.read<MyBloc>().update();
///     return const SizedBox();
///   }
/// }
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
