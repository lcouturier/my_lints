import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferStringInterpolationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_string_interpolation',
    'Prefer using string interpolation over string concatenation.',
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
    // On ne s'intéresse qu'à l'opérateur +
    if (node.operator.type.lexeme != '+') return;

    // Cas rapide : éviter les faux positifs évidents
    if (!_isStringConcatenation(node)) return;

    // Ne pas lint les cas non-string
    if (!_isLikelyStringContext(node)) return;

    rule.reportAtNode(node);
  }

  bool _isLikelyStringContext(BinaryExpression node) {
    final left = node.leftOperand;
    final right = node.rightOperand;

    return _looksLikeString(left) || _looksLikeString(right);
  }

  bool _looksLikeString(Expression expr) {
    if (expr is StringLiteral) return true;

    if (expr is SimpleIdentifier) {
      // heuristique : pas parfait mais stable en AST only
      return true;
    }

    if (expr is MethodInvocation) return true;

    return false;
  }

  bool _isStringConcatenation(BinaryExpression node) {
    final left = node.leftOperand;
    final right = node.rightOperand;

    return _isStringPart(left) || _isStringPart(right);
  }

  bool _isStringPart(Expression expr) {
    // String literal direct
    if (expr is StringLiteral) return true;

    // interpolation déjà correcte => ne pas lint
    if (expr is InterpolationExpression) return false;

    // évite nombres / bool / etc
    if (expr is IntegerLiteral || expr is DoubleLiteral || expr is BooleanLiteral || expr is NullLiteral) {
      return false;
    }

    // fallback conservateur (identifiants possibles string)
    return true;
  }
}
