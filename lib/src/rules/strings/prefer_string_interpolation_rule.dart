import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Prefer using string interpolation over string concatenation.
///
/// example:
/// ```dart
/// // BAD
/// String greet(String name) => 'Hello, ' + name;
/// // GOOD
/// String greet(String name) => 'Hello, $name';
/// ```
class PreferStringInterpolationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_string_interpolation',
    'Prefer using string interpolation over string concatenation.',
    correctionMessage: 'Use string interpolation instead of concatenation.',
  );

  PreferStringInterpolationRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferStringInterpolationRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node case BinaryExpression(
      operator: Token(type: TokenType.PLUS),
      isLikelyStringContext: true,
      isStringConcatenation: true,
    )) {
      rule.reportAtNode(node);
    }
  }
}

extension on BinaryExpression {
  bool get isLikelyStringContext {
    final left = leftOperand;
    final right = rightOperand;

    return left.islooksLikeString || right.islooksLikeString;
  }

  bool get isStringConcatenation {
    final left = leftOperand;
    final right = rightOperand;

    return left.isStringPart || right.isStringPart;
  }
}

extension on Expression {
  bool get islooksLikeString {
    return switch (this) {
      StringLiteral() => true,
      SimpleIdentifier() => true,
      MethodInvocation() => true,
      _ => false,
    };
  }

  bool get isStringPart {
    if (this is StringLiteral) return true;
    if (this is InterpolationExpression) return false;
    if (this is IntegerLiteral || this is DoubleLiteral || this is BooleanLiteral || this is NullLiteral) {
      return false;
    }
    return true;
  }
}
