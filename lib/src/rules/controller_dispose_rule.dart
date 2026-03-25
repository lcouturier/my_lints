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

  final Set<String> _controllers = {};
  final Set<String> _disposed = {};
  final Map<String, FieldElement> _fields = {};
  MethodDeclaration? _disposeMethod;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.isStateClass) return;

    _controllers.clear();
    _disposed.clear();
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
          _fields[element.name ?? ''] = element;
          _controllers.add(element.name ?? '');
        }
      }
    }

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        _disposeMethod = member;
        member.body.visitChildren(_DisposeVisitor(_disposed));
      }

      if (member is MethodDeclaration && member.name.lexeme == 'initState') {
        member.body.visitChildren(
          _InitStateVisitor(fields: _fields, controllers: _controllers, controllerTypes: _controllerTypes),
        );
      }
    }

    if (_disposeMethod != null) {
      for (final c in _controllers.difference(_disposed)) {
        rule.reportAtNode(_disposeMethod!, arguments: [c]);
      }
    }
  }
}

class _InitStateVisitor extends RecursiveAstVisitor<void> {
  final Map<String, FieldElement> fields;
  final Set<String> controllers;
  final Set<String> controllerTypes;

  _InitStateVisitor({required this.fields, required this.controllers, required this.controllerTypes});

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final left = node.leftHandSide;
    final right = node.rightHandSide;

    final name = left.getName();
    if (name == null) return;

    final field = fields[name];
    if (field == null) return; // 🔒 garantit que c’est un field

    if (right is InstanceCreationExpression) {
      final typeName = right.constructorName.type.name.lexeme;

      final shouldTrack = controllerTypes.contains(typeName) || (right.staticType?.shouldBeDisposed() ?? false);

      if (shouldTrack) {
        controllers.add(name);
      }
    }

    super.visitAssignmentExpression(node);
  }
}

class _DisposeVisitor extends RecursiveAstVisitor<void> {
  final Set<String> disposed;

  _DisposeVisitor(this.disposed);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'dispose') return;

    final name = node.realTarget?.getName();
    if (name != null) {
      disposed.add(name);
    }

    super.visitMethodInvocation(node);
  }
}
