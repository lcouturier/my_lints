import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports functions whose cyclomatic complexity exceeds a threshold.
///
/// Complexity starts at one and increases for `if`, conditional expressions,
/// switch cases, loops, catch clauses, and `&&`/`||` operators. Extracting a
/// calculation into an appropriate library operation can reduce branching.
///
/// ## Example
///
/// ❌ Bad (when the configured threshold is below 3):
/// ```dart
/// int classify(int value) {
///   if (value < 0) return -1;
///   if (value == 0) return 0;
///   return 1;
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// int classify(int value) => value.compareTo(0);
/// ```
class AvoidHighCyclomaticComplexityRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_high_cyclomatic_complexity',
    'Function has high cyclomatic complexity ({0}). Consider extracting to smaller functions.',
    correctionMessage: 'Extract complex logic into separate functions.',
  );

  AvoidHighCyclomaticComplexityRule({required this.threshold})
    : super(name: code.name, description: code.problemMessage);

  final int threshold;

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor)
      ..addConstructorDeclaration(this, visitor)
      ..addFunctionExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidHighCyclomaticComplexityRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _verify(node.functionExpression.body, node.name.lexeme);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _verify(node.body, node.name.lexeme);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _verify(node.body, node.name?.lexeme ?? 'constructor');
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _verify(node.body, '<anonymous>');
  }

  void _verify(FunctionBody body, String functionName) {
    if (body is EmptyFunctionBody) return;

    final metrics = _CyclomaticComplexityMetrics();
    metrics.analyze(body);

    if (metrics.complexity > rule.threshold) {
      rule.reportAtNode(body, arguments: [metrics.complexity.toString()]);
    }
  }
}

class _CyclomaticComplexityMetrics extends RecursiveAstVisitor<void> {
  int complexity = 1; // Base complexity is 1

  void analyze(FunctionBody body) {
    body.accept(this);
  }

  @override
  void visitIfStatement(IfStatement node) {
    complexity++;
    super.visitIfStatement(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    complexity++;
    super.visitConditionalExpression(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    // Count each case (excluding default) as a branching point
    for (final member in node.members) {
      if (member is SwitchCase) {
        complexity++;
      }
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    // Count each case (excluding default) as a branching point
    complexity += node.cases.length;
    super.visitSwitchExpression(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    complexity++;
    super.visitForStatement(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    complexity++;
    super.visitWhileStatement(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    complexity++;
    super.visitDoStatement(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    complexity++;
    super.visitCatchClause(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type == TokenType.AMPERSAND_AMPERSAND || node.operator.type == TokenType.BAR_BAR) {
      complexity++;
    }
    super.visitBinaryExpression(node);
  }
}
