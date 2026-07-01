import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

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

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidI18nCurrentRule rule;

  _Visitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    ) when _hasBuildContextInScope(node)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node case PrefixedIdentifier(
      prefix: SimpleIdentifier(name: 'I18n'),
      identifier: SimpleIdentifier(name: 'current'),
    ) when _hasBuildContextInScope(node)) {
      rule.reportAtNode(node);
    }
  }

  bool _hasBuildContextInScope(AstNode node) {
    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method != null) {
      return _containsBuildContextParameter(method.parameters);
    }

    final function = node.thisOrAncestorOfType<FunctionDeclaration>();
    if (function != null) {
      return _containsBuildContextParameter(function.functionExpression.parameters);
    }

    return false;
  }

  bool _containsBuildContextParameter(FormalParameterList? parameters) {
    if (parameters == null) {
      return false;
    }

    for (final parameter in parameters.parameters.map((e) => e.unWrapped)) {
      if (parameter case SimpleFormalParameter(type: NamedType(name: Token(lexeme: 'BuildContext')))) {
        return true;
      }

      if (parameter case FieldFormalParameter(type: NamedType(name: Token(lexeme: 'BuildContext')))) {
        return true;
      }
    }

    return false;
  }
}
