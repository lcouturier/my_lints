import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that enforces the 'Cubit' suffix for Cubit classes.
///
/// This rule ensures that all classes extending Cubit have the 'Cubit' suffix
/// in their class name for consistency and clarity.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class UserState extends Cubit<UserState> {}
/// ```
///
/// ✅ Good:
/// ```dart
/// class UserStateCubit extends Cubit<UserState> {}
/// ```
class AddCubitSuffixRule extends AnalysisRule {
  static LintCode code = const LintCode('add_cubit_suffix_rule', 'Consider add cubit suffix to {0}.');

  AddCubitSuffixRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AddCubitSuffixRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isCubitClass: true, :final name) when !name.lexeme.endsWith('Cubit')) {
      rule.reportAtToken(name, arguments: [name.lexeme]);
    }
  }
}
