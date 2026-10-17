import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that discourages using BuildContext in initState and dispose methods.
///
/// Using context in initState can be unsafe because the widget is not fully built yet.
/// Using context in dispose can also cause issues. Use post-frame callbacks instead.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   Navigator.of(context).push(...);
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     Navigator.of(context).push(...);
///   });
/// }
/// ```
class AvoidContextInInitStateRule extends AnalysisRule {
  static LintCode code = const LintCode('avoid_context_in_initState', "Don't use 'context' in this method.");

  AvoidContextInInitStateRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidContextInInitStateRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterWidget) return;

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'initState') {
        final visitor = _ContextInInitStateVisitor();
        member.body.visitChildren(visitor);
        final contextUse = visitor.contextUse;
        if (contextUse != null) {
          rule.reportAtNode(contextUse);
        }
      }
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        final visitor = _ContextInDisposeVisitor();
        member.body.visitChildren(visitor);
        final contextUse = visitor.contextUse;
        if (contextUse != null) {
          rule.reportAtNode(contextUse);
        }
      }
    }
  }
}

class _ContextInInitStateVisitor extends RecursiveAstVisitor<void> {
  static const _safeAsyncMethods = {'addPostFrameCallback', 'scheduleFrameCallback', 'addListener'};

  AstNode? contextUse;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node case MethodInvocation(
      target: PropertyAccess(propertyName: SimpleIdentifier(name: 'endOfFrame')),
      methodName: SimpleIdentifier(name: 'then'),
    )) {
      return;
    }

    if (node case MethodInvocation(
      target: SimpleIdentifier(name: 'BlocProvider'),
      methodName: SimpleIdentifier(name: 'of'),
    )) {
      return;
    }

    if (node case MethodInvocation(
      target: SimpleIdentifier(name: 'context'),
      methodName: SimpleIdentifier(name: 'read'),
    )) {
      return;
    }

    final name = node.methodName.name;
    if (_safeAsyncMethods.contains(name)) {
      return;
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node case SimpleIdentifier(isBuildContext: true)) {
      contextUse = node;
    }
  }
}

class _ContextInDisposeVisitor extends RecursiveAstVisitor<void> {
  AstNode? contextUse;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node case SimpleIdentifier(isBuildContext: true)) {
      contextUse = node;
    }
  }
}

extension on SimpleIdentifier {
  bool get isBuildContext => staticType?.element?.name == 'BuildContext';
}
