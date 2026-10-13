import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
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

  AvoidUnnecessaryNullableReturnRule()
      : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidUnnecessaryNullableReturnRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkNullableReturnNeverReturnsNull(
        node, node.returnType, node.functionExpression.body);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkNullableReturnNeverReturnsNull(node, node.returnType, node.body);
  }

  void _checkNullableReturnNeverReturnsNull(
      AstNode node, TypeAnnotation? returnType, FunctionBody body) {
    // Skip if no return type (inferred)
    if (returnType == null) return;

    // Skip if return type is not nullable
    if (returnType is! NamedType || returnType.question == null) return;

    // Skip abstract methods (no body to analyze)
    if (body is EmptyFunctionBody) return;

    // Skip methods that override or implement other methods
    if (_isOverrideOrImplementation(node)) return;

    // Skip methods named copyWith (pattern convention)
    if (_isCopyWith(node)) return;

    // Skip methods with external keyword
    if (_isExternal(node)) return;

    // Check if any return statement returns null
    if (!_canReturnNull(body)) {
      rule.reportAtNode(returnType);
    }
  }

  bool _isOverrideOrImplementation(AstNode node) {
    // Check if the node has @override annotation
    if (node is FunctionDeclaration) {
      return node.metadata
          .any((annotation) => annotation.name.name == 'override');
    }
    if (node is MethodDeclaration) {
      return node.metadata
          .any((annotation) => annotation.name.name == 'override');
    }

    return false;
  }

  bool _isCopyWith(AstNode node) {
    if (node is FunctionDeclaration) {
      return node.name.lexeme == 'copyWith';
    }
    if (node is MethodDeclaration) {
      return node.name.lexeme == 'copyWith';
    }

    return false;
  }

  bool _isExternal(AstNode node) {
    if (node is FunctionDeclaration) {
      return node.externalKeyword != null;
    }
    if (node is MethodDeclaration) {
      return node.externalKeyword != null;
    }

    return false;
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
      // Explicit `return;` - effectively returns null for nullable types
      hasNullReturn = true;
    } else if (_canReturnNull(expression)) {
      // Expression can return null
      hasNullReturn = true;
    }
    // Continue to check other return statements
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    // Check expression-bodied functions (arrow syntax)
    if (_canReturnNull(node.expression)) {
      hasNullReturn = true;
    }
    super.visitExpressionFunctionBody(node);
  }

  bool _canReturnNull(Expression expression) {
    // Direct null literal
    if (expression is NullLiteral) return true;

    // Ternary expression that can return null
    if (expression is ConditionalExpression) {
      return _canReturnNull(expression.thenExpression) ||
          _canReturnNull(expression.elseExpression);
    }

    return false;
  }
}
