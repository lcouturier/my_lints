import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

class ControllerDisposeRule extends AnalysisRule {
  ControllerDisposeRule()
    : super(name: 'controller_dispose_check', description: 'Controllers should be disposed properly');

  static const LintCode code = LintCode('controller_dispose_check', 'Controller "{0}" is not disposed.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final ControllerDisposeRule rule;

  _Visitor(this.rule);

  static const _controllerTypes = {
    'TextEditingController',
    'FocusNode',
    'ScrollController',
    'AnimationController',
    'TabController',
    'PageController',
  };

  final Set<FieldElement> _controllers = {};
  final Set<FieldElement> _disposed = {};
  final Set<FieldElement> _fields = {};
  MethodDeclaration? _disposeMethod;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isFlutterStateClass) return;

    _controllers.clear();
    _disposed.clear();
    _fields.clear();
    _disposeMethod = null;

    for (final member in node.members.whereType<FieldDeclaration>()) {
      final type = member.fields.type?.type;
      if (type == null) continue;

      final typeName = type.element?.name;
      final isController = _controllerTypes.contains(typeName) || type.shouldBeDisposed();

      if (!isController) continue;

      for (final variable in member.fields.variables) {
        final element = variable.declaredFragment?.element;
        if (element is FieldElement) {
          _fields.add(element);

          if (variable.initializer?.staticType?.shouldBeDisposed() ?? false) {
            _controllers.add(element);
          }
        }
      }
    }

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        _disposeMethod = member;
        member.body.visitChildren(_DisposeVisitor(disposed: _disposed, fields: _fields));
      }

      if (member is MethodDeclaration && member.name.lexeme == 'initState') {
        member.body.visitChildren(_InitStateVisitor(fields: _fields, controllers: _controllers));
      }
    }

    final missingControllers = _controllers.difference(_disposed);
    for (final item in missingControllers) {
      rule.reportAtNode(_disposeMethod ?? node, arguments: [item.name ?? '']);
    }
  }
}

class _InitStateVisitor extends RecursiveAstVisitor<void> {
  final Set<FieldElement> fields;
  final Set<FieldElement> controllers;

  _InitStateVisitor({required this.fields, required this.controllers});

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final right = node.rightHandSide;

    final field = _resolveFieldElement(node.leftHandSide);

    if (field != null && fields.contains(field) && right.staticType?.shouldBeDisposed() == true) {
      controllers.add(field);
    }

    super.visitAssignmentExpression(node);
  }
}

class _DisposeVisitor extends RecursiveAstVisitor<void> {
  final Set<FieldElement> disposed;
  final Set<FieldElement> fields;

  _DisposeVisitor({required this.disposed, required this.fields});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'dispose') {
      final element = _resolveFieldElement(node.realTarget);
      if (element != null && fields.contains(element)) {
        disposed.add(element);
      }
    }

    super.visitMethodInvocation(node);
  }
}

FieldElement? _resolveFieldElement(Expression? expression) {
  final target = expression?.unParenthesized;

  return switch (target) {
    SimpleIdentifier(element: final FieldElement element) => element,
    PropertyAccess(propertyName: SimpleIdentifier(element: final FieldElement element)) => element,
    PrefixedIdentifier(identifier: SimpleIdentifier(element: final FieldElement element)) => element,
    _ => null,
  };
}
