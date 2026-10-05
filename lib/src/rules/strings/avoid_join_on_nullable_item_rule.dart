import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidJoinOnNullableItemRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_join_on_nullable_item',
    'Avoid calling join() on an Iterable containing nullable items or dynamic types.',
    correctionMessage: 'Ensure the Iterable does not contain null values before calling join() by calling whereType().',
  );

  AvoidJoinOnNullableItemRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidJoinOnNullableItemRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(methodName: SimpleIdentifier(name: 'join'), :final target) when target != null) {
      final type = target.staticType;
      if (type is! InterfaceType) return;
      if (type.typeArguments.isEmpty) return;

      final itemType = type.typeArguments.first;
      if (itemType is DynamicType) {
        rule.reportAtNode(node.methodName);
        return;
      }
      final isNullable = itemType.nullabilitySuffix == NullabilitySuffix.question;

      if (isNullable) {
        rule.reportAtNode(node.methodName);
      }
    }

    // final element = node.methodName.element;
    // if (!(element is MethodElement && element.name == 'join' && element.library.isDartCore)) return;

    // final target = node.target;
    // if (target == null) return;

    // final type = target.staticType;
    // if (type is! InterfaceType) return;
    // if (type.typeArguments.isEmpty) return;

    // final itemType = type.typeArguments.first;
    // final isNullable = itemType.nullabilitySuffix == NullabilitySuffix.question;

    // if (isNullable) {
    //   rule.reportAtNode(node);
    // }
  }
}
