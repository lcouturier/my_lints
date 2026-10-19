import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that reports `late` instance fields that are initialized in the constructor.
///
/// Use constructor parameters or initializer lists instead of `late` fields that are
/// immediately assigned in the constructor. This makes the initialization explicit and
/// avoids potential `LateInitializationError` at runtime.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class User {
///   late String name;
///   late int age;
///
///   User(String n, int a) {
///     name = n;
///     age = a;
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class User {
///   final String name;
///   final int age;
///
///   User(this.name, this.age);
/// }
/// ```
///
/// ✅ Good (late with initializer):
/// ```dart
/// class User {
///   late String name = 'default';
/// }
/// ```
///
/// ✅ Good (late for lazy initialization):
/// ```dart
/// class User {
///   late String _cachedName;
///
///   String get name {
///     if (_cachedName.isEmpty) {
///       _cachedName = fetchName();
///     }
///     return _cachedName;
///   }
/// }
/// ```
@Deprecated('Work in progress')
class AvoidLateInitializationInConstructorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_late_initialization_in_constructor',
    'Avoid late fields initialized in constructor',
    correctionMessage: 'Use constructor parameters or initializer lists instead of late fields',
    severity: DiagnosticSeverity.WARNING,
  );

  AvoidLateInitializationInConstructorRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidLateInitializationInConstructorRule rule;

  _Visitor(this.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.isStatic) return;

    for (final variable in node.fields.variables) {
      // Check if field is late without initializer
      if (variable.isLate && variable.initializer == null) {
        if (_isAssignedInConstructor(variable.name.lexeme, node)) {
          rule.reportAtToken(variable.name);
        }
      }
    }
  }

  bool _isAssignedInConstructor(String fieldName, FieldDeclaration field) {
    final classDeclaration = field.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return false;

    for (final member in classDeclaration.members) {
      if (member is ConstructorDeclaration) {
        // Check if field is assigned in initializer list
        for (final initializer in member.initializers) {
          if (initializer is ConstructorFieldInitializer) {
            if (initializer.fieldName.name == fieldName) {
              return true;
            }
          }
        }

        // Check if field is assigned in constructor body
        final assignmentFinder = _FieldAssignmentFinder(fieldName);
        member.body.accept(assignmentFinder);
        if (assignmentFinder.found) {
          return true;
        }
      }
    }

    return false;
  }
}

class _FieldAssignmentFinder extends RecursiveAstVisitor<void> {
  final String fieldName;
  bool found = false;

  _FieldAssignmentFinder(this.fieldName);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide is SimpleIdentifier) {
      final identifier = node.leftHandSide as SimpleIdentifier;
      if (identifier.name == fieldName) {
        found = true;
        return;
      }
    }
    super.visitAssignmentExpression(node);
  }
}
