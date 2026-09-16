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
    return switch (type) {
      VoidType() => true,
      _ when type?.isFutureVoid ?? false => true,
      _ => false,
    };
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.metadata.any((annotation) => annotation.name.name == 'visibleForTesting')) return;
    if (!_isPublicMethod(node)) return;
    if (_isVoidOrFutureVoid(node.returnType?.type)) return;

    rule.reportAtToken(node.name);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isCubitClass) return;

    for (var member in node.members.whereType<MethodDeclaration>()) {
      visitMethodDeclaration(member);
    }
  }
}
