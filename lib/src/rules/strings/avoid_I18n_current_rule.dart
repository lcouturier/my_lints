// ignore_for_file: file_names

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/helpers.dart';

/// A rule that reports `I18n.current` in functions and methods with a
/// `BuildContext` parameter.
///
/// Use the context-based localization accessor so the value follows the active
/// localization configuration.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// String title(BuildContext context) => I18n.current.title;
/// ```
///
/// ✅ Good:
/// ```dart
/// String title(BuildContext context) => I18n.of(context).title;
/// ```
class AvoidI18nCurrentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_i18n_current',
    'Avoid using I18n.current. Consider using I18n.of(context) instead.',
    correctionMessage: 'Replace I18n.current with I18n.of(context) for better readability and maintainability.',
  );

  AvoidI18nCurrentRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addMethodDeclaration(this, visitor)
      ..addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidI18nCurrentRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final visitor = _I18nCurrentVisitor(rule);
    node.body.accept(visitor);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final visitor = _I18nCurrentVisitor(rule);
    node.functionExpression.body.accept(visitor);
  }
}

class _I18nCurrentVisitor extends RecursiveAstVisitor<void> {
  final AvoidI18nCurrentRule rule;

  _I18nCurrentVisitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (isI18nCurrentAccess(node) && getContextName(node) != null) {
      rule.reportAtNode(node);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (isI18nCurrentAccess(node) && getContextName(node) != null) {
      rule.reportAtNode(node);
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // A local function is analyzed by its own registered visitor.
  }
}
