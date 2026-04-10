import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class AvoidReturningValueFromCubitMethodsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_returning_value_from_cubit_methods',
    'Cubit methods should not return values. Emit states instead.',
    correctionMessage: 'Listen to a Cubit state change instead',
  );

  AvoidReturningValueFromCubitMethodsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AvoidReturningValueFromCubitMethodsRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isCubitClass) return;

    for (final member
        in node.members
            .whereType<MethodDeclaration>()
            .where((e) => !e.isGetter)
            .where((e) => !e.name.lexeme.startsWith('_'))) {
      if (member.returnType?.toString() != 'void' && member.returnType?.toString() != 'Future<void>') {
        rule.reportAtToken(member.name);
      }
    }
  }
}
