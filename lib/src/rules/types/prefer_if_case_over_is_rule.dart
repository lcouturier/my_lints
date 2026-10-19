import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prefers object patterns when a type check is followed by
/// property access on the checked value.
///
/// An if-case object pattern can check the type and bind the needed properties
/// in one step.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// if (state is ErrorState) {
///   print(state.error);
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// if (state case ErrorState(:final error)) {
///   print(error);
/// }
/// ```
class PreferIfCaseOverIsRule extends AnalysisRule {
  PreferIfCaseOverIsRule() : super(name: code.name, description: code.problemMessage);

  static const LintCode code = LintCode(
    'prefer_if_case_over_is',
    'Use an if-case object pattern to access properties of the checked value.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addIfStatement(this, _Visitor(this));
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final PreferIfCaseOverIsRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    if (node.expression case IsExpression(expression: SimpleIdentifier(:final name), notOperator: null)) {
      var found = false;
      node.thenStatement.visitChildren(_PropertyAccessFinder(name: name, onFound: () => found = true));
      if (found) {
        rule.reportAtNode(node.expression);
      }
    }

    super.visitIfStatement(node);
  }
}

class _PropertyAccessFinder extends RecursiveAstVisitor<void> {
  _PropertyAccessFinder({required this.name, required this.onFound});

  final String name;
  final void Function() onFound;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == name) {
      onFound();
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.target case SimpleIdentifier(name: final targetName) when targetName == name) {
      onFound();
    }
    super.visitPropertyAccess(node);
  }
}
