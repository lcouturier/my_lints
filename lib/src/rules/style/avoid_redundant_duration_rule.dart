import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports named `Duration` components given the integer literal `0`.
///
/// Remove zero-valued components because they do not change the duration.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// const duration = Duration(seconds: 0);
/// ```
///
/// ✅ Good:
/// ```dart
/// const duration = Duration();
/// ```
class AvoidRedundantDurationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_redundant_duration',
    'Redundant Duration constructor can be simplified.',
    correctionMessage: 'Remove the argument.',
  );

  AvoidRedundantDurationRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidRedundantDurationRule rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    const validFields = {'days', 'hours', 'minutes', 'seconds', 'milliseconds', 'microseconds'};

    if (node case InstanceCreationExpression(
      constructorName: ConstructorName(type: NamedType(name: Token(lexeme: 'Duration'))),
      argumentList: ArgumentList(:final arguments),
    )) {
      for (final argument in arguments.whereType<NamedExpression>()) {
        final name = argument.name.label.name;
        if (validFields.contains(name) &&
            argument.expression is IntegerLiteral &&
            (argument.expression as IntegerLiteral).value == 0) {
          rule.reportAtNode(argument);
        }
      }
    }
  }
}
