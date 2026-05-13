import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
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

  bool _isPublicMethod(MethodDeclaration m) => !m.isGetter && !m.name.lexeme.startsWith('_');

  bool _isVoidOrFutureVoid(DartType? type) {
    if (type is VoidType) return true;

    if (type?.isFutureVoid ?? false) {
      return true;
    }

    return false;
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isCubitClass) return;

    for (final member in node.members.whereType<MethodDeclaration>()) {
      if (member.metadata.any((annotation) => annotation.name.name == 'visibleForTesting')) return;

      if (_isPublicMethod(member)) {
        if (!_isVoidOrFutureVoid(member.returnType?.type)) {
          rule.reportAtToken(member.name);
        }
      }
    }
  }
}
