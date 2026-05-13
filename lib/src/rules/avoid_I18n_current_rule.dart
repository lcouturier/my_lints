import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidI18nCurrentRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_i18n_current',
    'Avoid using I18n.current. Consider using context.i18n instead.',
    correctionMessage: 'Replace I18n.current with context.i18n for better readability and maintainability.',
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
    AstNode? current = node;

    while (current != null) {
      if (current is FunctionDeclaration) {
        if (_containsBuildContextParameter(current.functionExpression.parameters)) {
          return true;
        }
      }

      if (current is MethodDeclaration) {
        if (_containsBuildContextParameter(current.parameters)) {
          return true;
        }
      }

      current = current.parent;
    }

    return false;
  }

  bool _containsBuildContextParameter(FormalParameterList? parameters) {
    if (parameters == null) {
      return false;
    }

    for (final parameter in parameters.parameters) {
      final formalParameter = switch (parameter) {
        DefaultFormalParameter() => parameter.parameter,
        _ => parameter,
      };

      if (formalParameter case SimpleFormalParameter(type: NamedType(name: Token(lexeme: 'BuildContext')))) {
        return true;
      }

      if (formalParameter case FieldFormalParameter(type: NamedType(name: Token(lexeme: 'BuildContext')))) {
        return true;
      }
    }

    return false;
  }
}

extension on DartType {
  // ignore: unused_element
  bool get isBuildContext {
    if (this is! InterfaceType) {
      return false;
    }

    final interfaceType = this as InterfaceType;
    return interfaceType.element.name == 'BuildContext' && interfaceType.element.library.name == 'widgets';
  }
}
