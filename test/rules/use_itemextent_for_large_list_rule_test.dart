import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/use_itemextent_for_large_list_rule.dart';
import 'package:path/path.dart' as p;

/// The example package must be resolvable: `ListView.builder(...)` is only an
/// [InstanceCreationExpression] once the unit is resolved.
final String _examplePath = p.normalize(
  p.join(Directory.current.path, 'example', 'lib', 'use_itemextent_for_large_list.dart'),
);

/// Under `flutter test` the process is `flutter_tester`, so the Dart SDK cannot
/// be derived from the running executable.
String get _sdkPath {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];

  return flutterRoot == null
      ? p.dirname(p.dirname(Platform.resolvedExecutable))
      : p.join(flutterRoot, 'bin', 'cache', 'dart-sdk');
}

void main() {
  group('UseItemextentForLargeListRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = UseItemextentForLargeListRule();

      expect(rule.diagnosticCode.name, 'use_itemextent_for_large_list');
      expect(rule.diagnosticCode.problemMessage, 'Use itemExtent for large lists.');
    });
  });

  group('UseItemextentForLargeListRule detection logic', () {
    late Map<String, bool> results;

    setUpAll(() async {
      results = await _analyzeExample();
    });

    test('reports a ListView.builder inside a StatelessWidget', () {
      expect(results['MyWidget'], isTrue);
    });

    test('reports a ListView.builder inside a top-level function', () {
      expect(results['buildList'], isTrue);
    });

    test('reports a ListView.builder inside a plain class', () {
      expect(results['ListFactory'], isTrue);
    });

    test('does not report when prototypeItem is provided', () {
      expect(results['MyWidgetWithPrototypeItem'], isFalse);
    });

    test('does not report when itemExtent is provided', () {
      expect(results['MyWidgetWithItemExtent'], isFalse);
    });

    // The pattern also matches the default `ListView(children: [...])`
    // constructor, which has no extent either. See discussion in #26.
    test('reports a default ListView without extent', () {
      expect(results['MyWidgetClassic'], isTrue);
    });
  });
}

/// Maps each enclosing declaration name to whether its `ListView` is reported.
Future<Map<String, bool>> _analyzeExample() async {
  expect(File(_examplePath).existsSync(), isTrue, reason: 'Missing example file at $_examplePath');

  final collection = AnalysisContextCollection(includedPaths: [_examplePath], sdkPath: _sdkPath);
  final session = collection.contextFor(_examplePath).currentSession;
  final result = await session.getResolvedUnit(_examplePath);
  expect(result, isA<ResolvedUnitResult>(), reason: 'Run `flutter pub get` in example/ first');

  final visitor = _Collector();
  (result as ResolvedUnitResult).unit.accept(visitor);

  return visitor.results;
}

class _Collector extends RecursiveAstVisitor<void> {
  final Map<String, bool> results = {};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme == 'ListView') {
      results[_enclosingName(node)] = node.isListViewMissingExtent;
    }

    super.visitInstanceCreationExpression(node);
  }

  String _enclosingName(AstNode node) {
    for (AstNode? current = node; current != null; current = current.parent) {
      switch (current) {
        case ClassDeclaration(:final name):
          return name.lexeme;
        case FunctionDeclaration(:final name):
          return name.lexeme;
      }
    }

    return '<unknown>';
  }
}
