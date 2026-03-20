import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class ControllerDisposeRule extends AnalysisRule {
  ControllerDisposeRule()
    : super(name: 'controller_dispose_check', description: 'Controllers should be disposed properly');

  static final LintCode code = LintCode('controller_dispose_check', 'Controller "{0}" is not disposed.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _ControllerDisposeVisitor(this));
  }
}

class _ControllerDisposeVisitor extends RecursiveAstVisitor<void> {
  final ControllerDisposeRule rule;

  _ControllerDisposeVisitor(this.rule);

  static const _controllerTypes = {
    'TextEditingController',
    'FocusNode',
    'ScrollController',
    'AnimationController',
    'TabController',
    'PageController',
  };

  final Set<String> _disposedControllers = {};
  final Set<String> _controllers = {};
  MethodDeclaration? _disposeMethod;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _controllers.clear();
    _disposedControllers.clear();
    _disposeMethod = null;

    if (!node.isStateClass) return;

    super.visitClassDeclaration(node);

    if (_disposeMethod == null) return;

    for (final controller in _controllers.where((e) => !_disposedControllers.contains(e))) {
      rule.reportAtNode(_disposeMethod!, arguments: [controller]);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final fieldType = node.fields.type;
    if (fieldType == null) return;

    if (fieldType is NamedType) {
      final typeName = fieldType.name.lexeme;
      if ((_controllerTypes.contains(typeName)) || (fieldType.type?.shouldBeDisposed() ?? false)) {
        for (final variable in node.fields.variables) {
          final name = variable.name.lexeme;
          if (variable.initializer != null) {
            _controllers.add(name);
          }
        }
      }
    }

    super.visitFieldDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme == 'initState') {
      final visitor = _InitStateVisitor(_controllers);
      node.accept(visitor);
    }

    if (node.name.lexeme == 'dispose') {
      _disposeMethod = node;

      final visitor = _DisposeVisitor();
      node.accept(visitor);

      _disposedControllers.addAll(visitor.disposedControllers);
    }
  }
}

class _InitStateVisitor extends RecursiveAstVisitor<void> {
  final Set<String> controllers;

  _InitStateVisitor(this.controllers);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final left = node.leftHandSide;
    final right = node.rightHandSide;

    if (left is SimpleIdentifier && right is InstanceCreationExpression) {
      final name = left.name;

      final shouldBeDisposed = left.staticType?.shouldBeDisposed() ?? false;
      if (controllers.contains(name) || shouldBeDisposed) {
        controllers.add(name);
      }
    }

    super.visitAssignmentExpression(node);
  }
}

class _DisposeVisitor extends RecursiveAstVisitor<void> {
  final Set<String> disposedControllers = {};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'dispose' && node.target != null) {
      final target = node.target;

      if (target is SimpleIdentifier) {
        disposedControllers.add(target.name);
      } else if (target is PrefixedIdentifier) {
        disposedControllers.add(target.identifier.name);
      }
    }

    super.visitMethodInvocation(node);
  }
}
