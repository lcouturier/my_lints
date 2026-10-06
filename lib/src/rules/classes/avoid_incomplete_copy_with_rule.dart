import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that enforces that the copyWith method of a class has all the parameters corresponding to the fields of the class.
///
/// example:
/// ```dart
/// class MyClass {
///   final String name;
///   final int age;
///   MyClass({required this.name, required this.age});
///   MyClass copyWith({String? name}) {
///     return MyClass(
///       name: name ?? this.name,
///       age: this.age, // Missing parameter for age
///     );
///   }
/// }
/// ```
class AvoidIncompleteCopyWithRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_incomplete_copy_with',
    'copyWith method is missing parameters',
    correctionMessage: 'Add missing parameters {0} to copyWith',
  );

  AvoidIncompleteCopyWithRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidIncompleteCopyWithRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme != 'copyWith') return;

    final fields = node.enclosingInstanceFieldNames;
    if (fields.isEmpty) return;

    final missing = node.missingCopyWithParameters(fields);
    if (missing.isEmpty) return;

    rule.reportAtToken(node.name, arguments: [missing.join(', ')]);
  }
}

extension CopyWithParametersExtension on MethodDeclaration {
  /// Returns the [fields] that have no matching named parameter, sorted by name.
  List<String> missingCopyWithParameters(Set<String> fields) {
    final named = parameters?.parameters
        .where((parameter) => parameter.isNamed)
        .map((parameter) => parameter.name?.lexeme)
        .nonNulls
        .toSet();

    return fields.difference(named ?? const <String>{}).toList()..sort();
  }
}
