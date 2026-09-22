import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidNullableBoolRule extends AnalysisRule {
  static const code = LintCode('avoid_nullable_bool', 'Avoid nullable bool', correctionMessage: 'Avoid nullable bool');

  AvoidNullableBoolRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFieldDeclaration(this, visitor)
      ..addVariableDeclarationList(this, visitor)
      ..addSimpleFormalParameter(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNullableBoolRule rule;

  _Visitor(this.rule);

  @override
  void visitNamedType(NamedType node) {
    if (node case NamedType(element: Element(name: 'bool', library: LibraryElement(isDartCore: true)), question: _?)) {
      if (_isInsideCopyWith(node)) {
        return;
      }

      rule.reportAtNode(node);
    }
  }

  bool _isInsideCopyWith(AstNode node) {
    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method?.name.lexeme == 'copyWith') {
      return true;
    }

    final function = node.thisOrAncestorOfType<FunctionDeclaration>();
    if (function?.name.lexeme == 'copyWith') {
      return true;
    }

    return false;
  }
}
