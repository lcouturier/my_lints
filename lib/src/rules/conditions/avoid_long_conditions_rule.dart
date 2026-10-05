import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Detects conditions that are too long or complex based on structural metrics.
///
/// This rule uses different metrics than AvoidComplicatedConditionalRule:
/// - Total number of tokens in the condition
/// - Number of unique variables involved
/// - Number of different operator types
///
/// ✅ GOOD:
/// ```dart
/// final isLoading = status == Status.loading;
/// final hasError = status == Status.error;
/// if (isLoading || hasError) {
///   // ...
/// }
/// ```
///
/// ❌ BAD:
/// ```dart
/// if (user != null && user.age > 18 && user.isActive && user.hasPermission && user.isVerified) {
///   // Too many variables and operators
/// }
/// ```
class AvoidLongConditionsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_long_conditions',
    'Conditions are too long or complex. Consider extracting to variables.',
    correctionMessage: 'Extract parts of the condition to named variables.',
  );

  AvoidLongConditionsRule({required this.maxTokens, required this.maxVariables, required this.maxOperatorTypes})
    : super(name: code.name, description: code.problemMessage);

  final int maxTokens;
  final int maxVariables;
  final int maxOperatorTypes;

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry
      ..addIfStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addConditionalExpression(this, visitor)
      ..addDoStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidLongConditionsRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    _verify(node.expression);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _verify(node.condition);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _verify(node.condition);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _verify(node.condition);
  }

  void _verify(Expression expression) {
    final condition = expression.unParenthesized;
    final metrics = _ConditionMetrics();
    metrics.analyze(condition);

    // Check if any threshold is exceeded
    if (metrics.tokenCount > rule.maxTokens ||
        metrics.variableCount > rule.maxVariables ||
        metrics.operatorTypeCount > rule.maxOperatorTypes) {
      rule.reportAtNode(expression);
    }
  }
}

class _ConditionMetrics extends RecursiveAstVisitor<void> {
  int tokenCount = 0;
  final Set<String> variables = {};
  final Set<TokenType> operatorTypes = {};

  void analyze(Expression expression) {
    // Count tokens by traversing the AST
    expression.accept(this);
    tokenCount = _countTokens(expression);
  }

  int _countTokens(AstNode node) {
    int count = 0;
    node.accept(_TokenCountingVisitor(onToken: (_) => count++));
    return count;
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // Exclude keywords and common constants
    if (!_isKeyword(node.name) && !_isConstant(node.name)) {
      variables.add(node.name);
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    operatorTypes.add(node.operator.type);
    super.visitBinaryExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    operatorTypes.add(node.operator.type);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    operatorTypes.add(node.operator.type);
    super.visitPostfixExpression(node);
  }

  int get variableCount => variables.length;
  int get operatorTypeCount => operatorTypes.length;

  bool _isKeyword(String name) {
    const keywords = {
      'true',
      'false',
      'null',
      'this',
      'super',
      'is',
      'as',
      'if',
      'else',
      'for',
      'while',
      'do',
      'switch',
      'case',
      'break',
      'continue',
      'return',
      'throw',
      'try',
      'catch',
      'finally',
      'new',
      'const',
      'final',
      'var',
      'let',
      'void',
      'int',
      'double',
      'num',
      'bool',
      'String',
      'List',
      'Map',
      'Set',
      'dynamic',
      'Object',
    };
    return keywords.contains(name);
  }

  bool _isConstant(String name) {
    return name.startsWith('k') && name.length > 1 && name[1].toUpperCase() == name[1];
  }
}

class _TokenCountingVisitor extends GeneralizingAstVisitor<void> {
  final void Function(Token) onToken;

  _TokenCountingVisitor({required this.onToken});

  @override
  void visitNode(AstNode node) {
    // Visit children first
    super.visitNode(node);

    // Count tokens for this node if it has them
    if (node is Expression) {
      _countTokensInExpression(node);
    }
  }

  void _countTokensInExpression(Expression expr) {
    if (expr is BinaryExpression) {
      onToken(expr.operator);
    } else if (expr is PrefixExpression) {
      onToken(expr.operator);
    } else if (expr is PostfixExpression) {
      onToken(expr.operator);
    } else if (expr is AssignmentExpression) {
      onToken(expr.operator);
    }
  }
}
