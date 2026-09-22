import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/type_checker.dart';

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
    final visitor = _I18nCurrentVisitor(rule, node);
    node.body.accept(visitor);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final visitor = _I18nCurrentVisitor(rule, node);
    node.functionExpression.body.accept(visitor);
  }
}

class _I18nCurrentVisitor extends RecursiveAstVisitor<void> {
  final AvoidI18nCurrentRule rule;
  final AstNode parent;
  final Map<int, (bool, String)> _contextCache = {};

  _I18nCurrentVisitor(this.rule, this.parent);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    )) {
      if (parent is MethodDeclaration) {
        final result = _getCachedContextName(parent);
        if (result.$1) {
          rule.reportAtNode(node);
        }
      }
      if (parent is FunctionDeclaration) {
        final result = _getCachedContextName(parent);
        if (result.$1) {
          rule.reportAtNode(node);
        }
      }
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node case PrefixedIdentifier(
      prefix: SimpleIdentifier(name: 'I18n'),
      identifier: SimpleIdentifier(name: 'current'),
    )) {
      if (parent is MethodDeclaration) {
        final result = _getCachedContextName(parent);
        if (result.$1) {
          rule.reportAtNode(node);
        }
      }
      if (parent is FunctionDeclaration) {
        final result = _getCachedContextName(parent);
        if (result.$1) {
          rule.reportAtNode(node);
        }
      }
    }
    super.visitPrefixedIdentifier(node);
  }

  (bool, String) _getCachedContextName(AstNode parent) {
    return _contextCache.putIfAbsent(parent.hashCode, () {
      if (parent is MethodDeclaration) {
        final parameters = parent.parameters?.parameters;
        if (parameters == null || parameters.isEmpty) return (false, '');

        final result = parameters.firstWhereOrElse(
          (e) => e.isBuildContext,
          (e) => (true, e.toString().split(' ')[1]),
          () => (false, ''),
        );
        _contextCache[parent.hashCode] = result;
        return result;
      }
      if (parent is FunctionDeclaration) {
        final parameters = parent.functionExpression.parameters?.parameters;
        if (parameters == null || parameters.isEmpty) return (false, '');

        final result = parameters.firstWhereOrElse(
          (e) => e.isBuildContext,
          (e) => (true, e.toString().split(' ')[1]),
          () => (false, ''),
        );
        _contextCache[parent.hashCode] = result;
        return result;
      }
      return (false, '');
    });
  }
}
