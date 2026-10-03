import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

/// A rule that prevents the use of positional record field access.
///
/// Example:
/// ```dart
/// final record = (1, 2);
/// print(record.$1); // ❌ Avoid this
/// print(record.$2); // ❌ Avoid this
/// ```
class AvoidPositionalRecordFieldAccessRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_positional_record_field_access',
    'Avoid positional record field access.',
    correctionMessage: 'Use named record field access instead of positional access.',
  );

  AvoidPositionalRecordFieldAccessRule() : super(name: code.name, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addPropertyAccess(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidPositionalRecordFieldAccessRule rule;

  _Visitor(this.rule);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      propertyName: SimpleIdentifier(:final name),
      realTarget: SimpleIdentifier(staticType: RecordType()),
    ) when (name.startsWith(r'$'))) {
      rule.reportAtNode(node);
    }
  }
}
