// ignore_for_file: unused_element

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that checks the position of lifecycle `super` calls in Flutter widgets.
///
/// In a widget `State` class, call `super.initState()` first and
/// `super.dispose()` last.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class MyState extends State<MyWidget> {
///   @override
///   void initState() {
///     initialize();
///     super.initState();
///   }
///
///   @override
///   void dispose() {
///     super.dispose();
///     cleanUp();
///   }
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class MyState extends State<MyWidget> {
///   @override
///   void initState() {
///     super.initState();
///     initialize();
///   }
///
///   @override
///   void dispose() {
///     cleanUp();
///     super.dispose();
///   }
/// }
class ProperSuperCallsRule extends AnalysisRule {
  static LintCode code = const LintCode(
    'proper_super_calls',
    "Ensure that 'super.initState()' and 'super.dispose()' are called in the correct order.",
  );

  ProperSuperCallsRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final ProperSuperCallsRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isFlutterStatefulWidget: true)) {
      final methods = {for (final member in node.members.whereType<MethodDeclaration>()) member.name.lexeme: member};
      final initState = methods["initState"];
      final dispose = methods["dispose"];

      if (initState != null) {
        final visitor = _InitStateVisitor(method: initState);
        initState.body.visitChildren(visitor);
        final (:hasSuperCalled, :statement) = visitor.hasSuperCalled;
        if (!hasSuperCalled) {
          rule.reportAtNode(statement);
        }
      }

      if (dispose != null) {
        final visitor = _DisposeVisitor(method: dispose);
        dispose.body.visitChildren(visitor);
        final (:hasSuperCalled, :statement) = visitor.hasSuperCalled;
        if (!hasSuperCalled) {
          rule.reportAtNode(statement);
        }
      }
    }
  }
}

typedef _VisitorResult = ({bool hasSuperCalled, Expression? statement});

class _InitStateVisitor extends SimpleAstVisitor<void> {
  _InitStateVisitor({required this.method});

  final MethodDeclaration method;
  late _VisitorResult hasSuperCalled = (hasSuperCalled: false, statement: null);

  @override
  void visitBlock(Block node) {
    if (node case Block(:final statements) when statements.isNotEmpty && statements.first is ExpressionStatement) {
      for (var i = 0; i < statements.length; i++) {
        if (statements[i] case ExpressionStatement(
          expression: MethodInvocation(methodName: SimpleIdentifier(name: 'initState'), target: SuperExpression()) &&
              final expr,
        )) {
          hasSuperCalled = (hasSuperCalled: i == 0, statement: expr);
        }
      }
    }

    super.visitBlock(node);
  }
}

class _DisposeVisitor extends SimpleAstVisitor<void> {
  _DisposeVisitor({required this.method});

  final MethodDeclaration method;
  late _VisitorResult hasSuperCalled = (hasSuperCalled: false, statement: null);

  @override
  void visitBlock(Block node) {
    if (node case Block(:final statements) when statements.isNotEmpty && statements.last is ExpressionStatement) {
      for (var i = 0; i < statements.length; i++) {
        if (statements[i] case ExpressionStatement(
          expression: MethodInvocation(methodName: SimpleIdentifier(name: 'dispose'), target: SuperExpression()) &&
              final expr,
        )) {
          hasSuperCalled = (hasSuperCalled: (i == (statements.length - 1)), statement: expr);
        }
      }
    }

    super.visitBlock(node);
  }
}
