import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports functions and methods with nullable return types that
/// never return null in their body.
///
/// Use a non-nullable return type when the function cannot return null.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// String? getName() {
///   return 'John';
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// String getName() {
///   return 'John';
/// }
/// ```
///
/// The rule excludes:
/// - Abstract methods (no body to analyze)
/// - Methods that override or implement other methods (signature must match)
/// - Methods with `late` return types (deferred analysis)
/// - Methods named `copyWith` (pattern convention)
class AvoidUnnecessaryNullableReturnRule extends AnalysisRule {
  static const code = LintCode(
    'avoid_unnecessary_nullable_return',
    'Avoid unnecessary nullable return type',
    correctionMessage: 'Remove the nullable marker from the return type',
  );

  AvoidUnnecessaryNullableReturnRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnnecessaryNullableReturnRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkNullableReturnNeverReturnsNull(node, node.returnType, node.functionExpression.body);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkNullableReturnNeverReturnsNull(node, node.returnType, node.body);
  }

  void _checkNullableReturnNeverReturnsNull(AstNode node, TypeAnnotation? returnType, FunctionBody body) {
    if (returnType == null) return;
    if (returnType is! NamedType || returnType.question == null) return;
    if (body is EmptyFunctionBody) return;
    if (node.isOverride) return;
    if (node.isCopyWith) return;
    if (node.isExternal) return;
    if (_canReturnNull(body)) return;

    rule.reportAtNode(returnType);
  }

  bool _canReturnNull(FunctionBody body) {
    final visitor = _NullReturnVisitor();
    body.accept(visitor);
    return visitor.hasNullReturn;
  }
}

class _NullReturnVisitor extends RecursiveAstVisitor<void> {
  bool hasNullReturn = false;

  @override
  void visitReturnStatement(ReturnStatement node) {
    final expression = node.expression;
    if (expression == null) {
      hasNullReturn = true;
    } else if (_canReturnNull(expression)) {
      hasNullReturn = true;
    }
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (_canReturnNull(node.expression)) {
      hasNullReturn = true;
    }
    super.visitExpressionFunctionBody(node);
  }

  bool _canReturnNull(Expression expression) {
    return switch (expression) {
      NullLiteral() => true,
      ConditionalExpression(thenExpression: final thenExpr, elseExpression: final elseExpr) =>
        _canReturnNull(thenExpr) || _canReturnNull(elseExpr),
      _ => false,
    };
  }
}

extension on AstNode {
  bool get isCopyWith {
    return switch (this) {
      FunctionDeclaration(name: Token(lexeme: "copyWith")) => true,
      MethodDeclaration(name: Token(lexeme: "copyWith")) => true,
      _ => false,
    };
  }

  bool get isExternal {
    return switch (this) {
      FunctionDeclaration(externalKeyword: final externalKeyword) => externalKeyword != null,
      MethodDeclaration(externalKeyword: final externalKeyword) => externalKeyword != null,
      _ => false,
    };
  }

  bool get isOverride {
    return switch (this) {
      FunctionDeclaration(metadata: final metadata) => metadata.any((e) => e.name.name == 'override'),
      MethodDeclaration(metadata: final metadata) => metadata.any((e) => e.name.name == 'override'),
      _ => false,
    };
  }
}
