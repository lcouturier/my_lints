import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';

List<AstNode> runAnalysisRule(AnalysisRule rule, String source) {
  return runAnalysisRuleOnUnit(rule, parseString(content: source).unit);
}

Set<String> registeredNodeTypes(AnalysisRule rule) {
  final registry = _TestRuleVisitorRegistry();
  rule.registerNodeProcessors(registry, _TestRuleContext());
  return registry.registeredNodeTypes;
}

List<AstNode> runAnalysisRuleOnUnit(AnalysisRule rule, CompilationUnit unit) {
  final registry = _TestRuleVisitorRegistry();
  final reporter = _TestDiagnosticReporter();
  rule.reporter = reporter;
  rule.registerNodeProcessors(registry, _TestRuleContext());

  unit.accept(_RuleVisitorDispatcher(registry));
  return reporter.reportedNodes;
}

class _TestRuleContext implements RuleContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestRuleVisitorRegistry implements RuleVisitorRegistry {
  final Map<String, List<AstVisitor>> _visitors = {};

  Set<String> get registeredNodeTypes => _visitors.keys.toSet();

  List<AstVisitor> visitorsFor(String nodeType) => _visitors[nodeType] ?? const [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    if (methodName.startsWith('Symbol("add') && invocation.positionalArguments.length == 2) {
      final nodeType = methodName.substring(11, methodName.length - 2);
      final visitor = invocation.positionalArguments[1] as AstVisitor;
      _visitors.putIfAbsent(nodeType, () => []).add(visitor);
    }
    return null;
  }
}

class _TestDiagnosticReporter implements DiagnosticReporter {
  final List<AstNode> reportedNodes = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName.toString() == 'Symbol("atNode")') {
      final node = invocation.positionalArguments.first as AstNode;
      if (!reportedNodes.contains(node)) {
        reportedNodes.add(node);
      }
      return const _TestDiagnostic();
    }
    return null;
  }
}

class _TestDiagnostic implements Diagnostic {
  const _TestDiagnostic();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RuleVisitorDispatcher extends RecursiveAstVisitor<void> {
  final _TestRuleVisitorRegistry registry;

  _RuleVisitorDispatcher(this.registry);

  void _dispatch(AstNode node, String nodeType) {
    for (final visitor in registry.visitorsFor(nodeType)) {
      node.accept(visitor);
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _dispatch(node, 'BinaryExpression');
    super.visitBinaryExpression(node);
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _dispatch(node, 'CompilationUnit');
    super.visitCompilationUnit(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _dispatch(node, 'ConditionalExpression');
    super.visitConditionalExpression(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _dispatch(node, 'DoStatement');
    super.visitDoStatement(node);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _dispatch(node, 'ExtensionDeclaration');
    super.visitExtensionDeclaration(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _dispatch(node, 'DoubleLiteral');
    super.visitDoubleLiteral(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    _dispatch(node, 'FieldDeclaration');
    super.visitFieldDeclaration(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _dispatch(node, 'ForStatement');
    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _dispatch(node, 'IfStatement');
    super.visitIfStatement(node);
  }

  @override
  void visitIfElement(IfElement node) {
    _dispatch(node, 'IfElement');
    super.visitIfElement(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _dispatch(node, 'IntegerLiteral');
    super.visitIntegerLiteral(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _dispatch(node, 'ListLiteral');
    super.visitListLiteral(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _dispatch(node, 'NamedType');
    super.visitNamedType(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _dispatch(node, 'PropertyAccess');
    super.visitPropertyAccess(node);
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    _dispatch(node, 'RecordLiteral');
    super.visitRecordLiteral(node);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    _dispatch(node, 'SimpleFormalParameter');
    super.visitSimpleFormalParameter(node);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    _dispatch(node, 'SpreadElement');
    super.visitSpreadElement(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _dispatch(node, 'SetOrMapLiteral');
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    _dispatch(node, 'VariableDeclarationList');
    super.visitVariableDeclarationList(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _dispatch(node, 'WhileStatement');
    super.visitWhileStatement(node);
  }
}
