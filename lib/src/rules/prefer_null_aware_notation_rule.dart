import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';

class PreferNullAwareNotationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_null_aware_notation',
    'Use null-aware notation (?.) instead of explicit null checks.',
    correctionMessage: '{0}.',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferNullAwareNotationRule()
    : super(
        name: 'prefer_null_aware_notation',
        description: 'Use null-aware notation (?.) instead of explicit null checks.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    // Implementation of node processors to detect explicit null checks and suggest using null-aware notation.
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferNullAwareNotationRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (!([() => (node.leftOperand is PropertyAccess), () => (node.leftOperand is SimpleIdentifier)]).any((e) => e())) {
      return;
    }

    if ((node.operator.type != TokenType.EQ_EQ) && (node.operator.type != TokenType.BANG_EQ)) return;
    if (node.rightOperand is! BooleanLiteral) return;
    final leftOperand = node.leftOperand;
    if (leftOperand.staticType != null && !leftOperand.staticType.isNullable) return;

    final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;
    final condition = node.toSource();
    final message =
        'Use ${isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)'} instead of $condition.';
    rule.reportAtNode(node, arguments: [message]);
  }
}

class PreferNullAwareNotationFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'many_lints.fix.prefer_null_aware_notation',
    DartFixKindPriority.inFile,
    'Prefer null-aware notation',
  );

  PreferNullAwareNotationFix({required super.context});

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! BinaryExpression) return;

    final leftOperand = node.leftOperand;
    final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;
    final replacement = isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)';

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(node), (b) => b.write(replacement));
    });
  }

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;
}
