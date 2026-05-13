import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidReduceUsageRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_reduce_usage',
    'Avoid reduce usage without verify length',
    correctionMessage: 'Avoid reduce usage without verify length',
  );

  AvoidReduceUsageRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);

    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidReduceUsageRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'reduce') return;

    if (node.realTarget is! SimpleIdentifier) {
      rule.reportAtNode(node);
      return;
    }

    final targetName = node.realTarget?.getName();
    if (targetName == null) return;

    if (node.parent case ConditionalExpression(
      condition: PrefixedIdentifier(
        prefix: SimpleIdentifier(name: final prefixName),
        identifier: SimpleIdentifier(name: 'isNotEmpty'),
      ),
      thenExpression: MethodInvocation(methodName: SimpleIdentifier(name: 'reduce')),
    ) when prefixName == targetName) {
      return;
    }

    if (node.parent case ConditionalExpression(
      condition: PrefixedIdentifier(
        prefix: SimpleIdentifier(name: final prefixName),
        identifier: SimpleIdentifier(name: 'isEmpty'),
      ),
      elseExpression: MethodInvocation(methodName: SimpleIdentifier(name: 'reduce')),
    ) when prefixName == targetName) {
      return;
    }

    final (found, statement) = node.getAncestor((node) => node is IfStatement);
    if (found) {
      if (statement case IfStatement(
        expression: PropertyAccess(
              target: SimpleIdentifier(name: final name),
              propertyName: SimpleIdentifier(name: 'isNotEmpty'),
            ) ||
            PrefixedIdentifier(
              prefix: SimpleIdentifier(name: final name),
              identifier: SimpleIdentifier(name: 'isNotEmpty'),
            ) ||
            PrefixExpression(
              operator: Token(type: TokenType.BANG),
              operand: PropertyAccess(
                target: SimpleIdentifier(name: final name),
                propertyName: SimpleIdentifier(name: 'isEmpty'),
              ),
            ) ||
            PrefixExpression(
              operator: Token(type: TokenType.BANG),
              operand: PrefixedIdentifier(
                prefix: SimpleIdentifier(name: final name),
                identifier: SimpleIdentifier(name: 'isEmpty'),
              ),
            ),
      ) when name == targetName) {
        return;
      }
    }

    rule.reportAtNode(node);
  }
}
