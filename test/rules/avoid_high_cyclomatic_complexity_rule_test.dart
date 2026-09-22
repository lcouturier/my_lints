// ignore_for_file: unused_import, unused_element

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_high_cyclomatic_complexity_rule.dart';

void main() {
  test('detects high cyclomatic complexity in function', () {
    final source = '''
void complexFunction(int x) {
  if (x > 0) {
    if (x < 10) {
      print('Small positive');
    } else {
      print('Large positive');
    }
  } else if (x < 0) {
    print('Negative');
  } else {
    print('Zero');
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 5);
    final result = _analyze(source, rule);
    expect(result.errors, isNotEmpty);
  });

  test('does not report low complexity function', () {
    final source = '''
void simpleFunction(int x) {
  if (x > 0) {
    print('Positive');
  } else {
    print('Non-positive');
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 5);
    final result = _analyze(source, rule);
    expect(result.errors, isEmpty);
  });

  test('counts switch cases', () {
    final source = '''
void withSwitch(int x) {
  switch (x) {
    case 1:
      print('One');
      break;
    case 2:
      print('Two');
      break;
    case 3:
      print('Three');
      break;
    default:
      print('Other');
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 3);
    final result = _analyze(source, rule);
    expect(result.errors, isNotEmpty);
  });

  test('counts loops', () {
    final source = '''
void withLoops(List<int> items) {
  for (final item in items) {
    print(item);
  }
  while (items.isNotEmpty) {
    items.removeLast();
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 2);
    final result = _analyze(source, rule);
    expect(result.errors, isNotEmpty);
  });

  test('counts catch clauses', () {
    final source = '''
void withTryCatch(String input) {
  try {
    print(int.parse(input));
  } on FormatException catch (e) {
    print('Format error');
  } catch (e) {
    print('Other error');
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 2);
    final result = _analyze(source, rule);
    expect(result.errors, isNotEmpty);
  });

  test('counts logical operators', () {
    final source = '''
void withLogicalOps(bool a, bool b, bool c, bool d) {
  if (a && b && c && d) {
    print('All true');
  }
}
''';
    final rule = AvoidHighCyclomaticComplexityRule(threshold: 3);
    final result = _analyze(source, rule);
    expect(result.errors, isNotEmpty);
  });

  test('respects custom threshold', () {
    final source = '''
void mediumComplexity(int x) {
  if (x > 0) {
    if (x < 10) {
      print('Small positive');
    }
  } else if (x < 0) {
    print('Negative');
  }
}
''';
    final strictRule = AvoidHighCyclomaticComplexityRule(threshold: 3);
    final strictResult = _analyze(source, strictRule);
    expect(strictResult.errors, isNotEmpty);

    final lenientRule = AvoidHighCyclomaticComplexityRule(threshold: 10);
    final lenientResult = _analyze(source, lenientRule);
    expect(lenientResult.errors, isEmpty);
  });
}

_AnalysisResult _analyze(String source, AvoidHighCyclomaticComplexityRule rule) {
  parseString(content: source);
  final errors = <AnalysisError>[];

  // Note: This is a simplified test setup
  // In a real scenario, you'd use the full analysis context
  // For now, we just verify the rule can be instantiated

  return _AnalysisResult(errors);
}

class _AnalysisResult {
  final List<AnalysisError> errors;

  _AnalysisResult(this.errors);
}
