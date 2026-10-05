import 'dart:io';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';

List<AstNode> runAnalysisRule(AnalysisRule rule, String source) {
  return runAnalysisRuleOnUnit(rule, parseString(content: source).unit);
}

Future<CompilationUnit> resolveSource(
  String source, {
  String fileName = 'test.dart',
  bool useWorkspacePackages = false,
}) async {
  final directory = useWorkspacePackages
      ? await Directory.current.createTemp('.my_lints_test_')
      : await Directory.systemTemp.createTemp('my_lints_test_');
  final path = directory.uri.resolve(fileName).toFilePath();
  await File(path).writeAsString(source);

  try {
    final collection = AnalysisContextCollection(includedPaths: [directory.path], sdkPath: _findDartSdkPath());
    try {
      final result = await collection.contextFor(path).currentSession.getResolvedUnit(path);
      if (result is! ResolvedUnitResult) {
        throw StateError('Could not resolve test source: $path');
      }
      return result.unit;
    } finally {
      await collection.dispose();
    }
  } finally {
    await directory.delete(recursive: true);
  }
}

String _findDartSdkPath() {
  String currentPath = File(Platform.resolvedExecutable).parent.path;

  while (true) {
    final directSdkMetadata = Directory(
      currentPath,
    ).uri.resolve('lib/_internal/sdk_library_metadata/lib/libraries.dart').toFilePath();
    if (File(directSdkMetadata).existsSync()) {
      return currentPath;
    }

    final bundledSdkPath = Directory(currentPath).uri.resolve('bin/cache/dart-sdk').toFilePath();
    final bundledSdkMetadata = Directory(
      bundledSdkPath,
    ).uri.resolve('lib/_internal/sdk_library_metadata/lib/libraries.dart').toFilePath();
    if (File(bundledSdkMetadata).existsSync()) {
      return bundledSdkPath;
    }

    final parentPath = Directory(currentPath).parent.path;
    if (parentPath == currentPath) {
      break;
    }
    currentPath = parentPath;
  }

  throw StateError('Could not find Dart SDK from ${Platform.resolvedExecutable}');
}

Set<String> registeredNodeTypes(AnalysisRule rule) {
  final registry = _TestRuleVisitorRegistry();
  rule.registerNodeProcessors(registry, _TestRuleContext());
  return registry.registeredNodeTypes;
}

List<AstNode> runAnalysisRuleOnUnit(AnalysisRule rule, CompilationUnit unit) {
  final registry = _TestRuleVisitorRegistry();
  final reporter = _TestDiagnosticReporter(unit);
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
  final CompilationUnit unit;
  final List<AstNode> reportedNodes = [];

  _TestDiagnosticReporter(this.unit);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();
    AstNode? node;
    if (memberName == 'Symbol("atNode")') {
      node = invocation.positionalArguments.first as AstNode;
    } else if (memberName == 'Symbol("atToken")') {
      final token = invocation.positionalArguments.first as Token;
      final finder = _NamedDeclarationFinder(token);
      unit.accept(finder);
      node = finder.declaration;
    }

    if (node != null) {
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

class _NamedDeclarationFinder extends RecursiveAstVisitor<void> {
  final Token token;
  AstNode? declaration;

  _NamedDeclarationFinder(this.token);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.name.offset == token.offset) {
      declaration = node;
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.offset == token.offset) {
      declaration = node;
    }
    super.visitMethodDeclaration(node);
  }
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
  void visitClassDeclaration(ClassDeclaration node) {
    _dispatch(node, 'ClassDeclaration');
    super.visitClassDeclaration(node);
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
  void visitExpressionStatement(ExpressionStatement node) {
    _dispatch(node, 'ExpressionStatement');
    super.visitExpressionStatement(node);
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
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _dispatch(node, 'InstanceCreationExpression');
    super.visitInstanceCreationExpression(node);
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
  void visitMethodDeclaration(MethodDeclaration node) {
    _dispatch(node, 'MethodDeclaration');
    super.visitMethodDeclaration(node);
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
  void visitSwitchExpression(SwitchExpression node) {
    _dispatch(node, 'SwitchExpression');
    super.visitSwitchExpression(node);
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

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _dispatch(node, 'GenericFunctionType');
    super.visitGenericFunctionType(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _dispatch(node, 'IndexExpression');
    super.visitIndexExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _dispatch(node, 'MethodInvocation');
    super.visitMethodInvocation(node);
  }

  @override
  void visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    _dispatch(node, 'RecordTypeAnnotation');
    super.visitRecordTypeAnnotation(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _dispatch(node, 'AssignmentExpression');
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _dispatch(node, 'PostfixExpression');
    super.visitPostfixExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _dispatch(node, 'FunctionExpressionInvocation');
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _dispatch(node, 'SimpleIdentifier');
    super.visitSimpleIdentifier(node);
  }
}
