import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/helpers.dart';

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
      ..addPropertyAccess(this, visitor)
      ..addPrefixedIdentifier(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> with ContextName {
  final AvoidI18nCurrentRule rule;
  final Map<AstNode, (bool, String)> _contextCache = {};

  _Visitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    )) {
      final (hasFix, paramName) = _getCachedContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      rule.reportAtNode(node);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node case PrefixedIdentifier(
      prefix: SimpleIdentifier(name: 'I18n'),
      identifier: SimpleIdentifier(name: 'current'),
    )) {
      final (hasFix, paramName) = _getCachedContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      rule.reportAtNode(node);
    }
    super.visitPrefixedIdentifier(node);
  }

  (bool, String) _getCachedContextName(
    MethodDeclaration? Function() getMethod,
    FunctionDeclaration? Function() getFunction,
  ) {
    final method = getMethod();
    if (method != null) {
      return _contextCache.putIfAbsent(method, () => getContextName(getMethod, getFunction));
    }

    final function = getFunction();
    if (function != null) {
      return _contextCache.putIfAbsent(function, () => getContextName(getMethod, getFunction));
    }

    return (false, '');
  }
}
