import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports nullable `List` return types, parameters, variables, and fields.
///
/// It excludes nullable list types inside methods named `copyWith`. Prefer an
/// empty list or a non-nullable parameter when `null` is not meaningful.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// List<int>? getValues() => null;
/// void updateValues(List<int>? values) {}
/// ```
///
/// ✅ Good:
/// ```dart
/// List<int> getValues() => [];
/// void updateValues(List<int> values) {}
/// ```
class AvoidUsageOfNullableListRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_usage_of_nullable_list',
    'Avoid usage of nullable list return type and parameters',
    correctionMessage:
        'Avoid using nullable list return type and parameters. Consider using non-nullable list instead.',
  );

  AvoidUsageOfNullableListRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _ListVisitor(this);
    registry
      ..addNamedType(this, visitor)
      ..addFunctionDeclaration(this, visitor);
  }
}

class _ListVisitor extends SimpleAstVisitor<void> {
  final AvoidUsageOfNullableListRule rule;

  _ListVisitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final returnType = node.returnType;
    if (returnType case NamedType(element: Element(name: 'List'), question: _?)) {
      rule.reportAtNode(returnType);
    }
  }

  @override
  void visitNamedType(NamedType node) {
    if (node case NamedType(element: Element(name: 'List'), question: _?)) {
      if (_isInsideCopyWith(node)) {
        return;
      }

      if (!_isRelevantUsage(node)) {
        return;
      }
      rule.reportAtNode(node);
    }
  }

  ///
  bool _isInsideCopyWith(AstNode node) {
    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    return switch (method) {
      MethodDeclaration(name: Token(lexeme: 'copyWith')) => true,
      _ => false,
    };
  }

  bool _isRelevantUsage(NamedType node) {
    final parent = node.parent;

    return [
      parent is SimpleFormalParameter,
      parent is VariableDeclarationList,
      parent is FieldDeclaration,
    ].any((element) => element);
  }
}
