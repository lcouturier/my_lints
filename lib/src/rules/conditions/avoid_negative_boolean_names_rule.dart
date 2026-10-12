import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that avoids negative boolean names.
///
/// Negative boolean names (e.g., `isDisabled`, `hasNoErrors`) make code harder to read.
/// Use positive boolean names instead.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// bool isDisabled = false;
/// bool hasNoErrors = true;
/// bool isInvalid = false;
/// ```
///
/// ✅ Good:
/// ```dart
/// bool isEnabled = true;
/// bool hasErrors = false;
/// bool isValid = true;
/// ```
class AvoidNegativeBooleanRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_negative_boolean',
    'Avoid negative boolean names.',
    correctionMessage: 'Use a positive boolean name to improve readability.',
  );

  AvoidNegativeBooleanRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addVariableDeclaration(this, visitor)
      ..addFormalParameterList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidNegativeBooleanRule rule;

  _Visitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final parent = node.parent;
    if (parent is! VariableDeclarationList) return;

    if (parent.type?.type?.isDartCoreBool ?? false) {
      if (node.name.lexeme.isNegativeName) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    for (final param in node.parameters.whereType<SimpleFormalParameter>()) {
      if (param.type?.type?.isDartCoreBool ?? false) {
        if (param.name?.lexeme.isNegativeName ?? false) {
          rule.reportAtNode(param);
        }
      }
    }
  }
}
