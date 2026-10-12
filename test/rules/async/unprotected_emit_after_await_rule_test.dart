import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/unprotected_emit_after_await_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UnProtectedEmitAfterAwaitRule', () {
    test('reports emit after await without an isClosed guard', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future<void>.delayed(Duration.zero);
    emit(state + 1);
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report emit after await with an isClosed guard', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future<void>.delayed(Duration.zero);
    if (isClosed) return;
    emit(state + 1);
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports emit after a branch-scoped isClosed guard', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future<void>.delayed(Duration.zero);
    if (!isClosed) {
      emit(state + 1);
    }
    emit(state + 2);
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
      expect(diagnostics.single.toSource(), 'emit(state + 2)');
    });

    test('reports emit after a non-exiting isClosed condition', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future<void>.delayed(Duration.zero);
    if (isClosed) {
      state;
    }
    emit(state + 1);
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
      expect(diagnostics.single.toSource(), 'emit(state + 1)');
    });

    test('reports emit after await in catch block', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      await Future<void>.delayed(Duration.zero);
      if (isClosed) return;
      emit(state + 1);
    } catch (e) {
      emit(state + 1);
    }
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report emit in catch when there was no await', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      emit(state + 1);
    } catch (e) {
      emit(state + 1);
    }
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report emit after await with an isClosed guard in catch block', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      await Future<void>.delayed(Duration.zero);
      if (isClosed) return;
      emit(state + 1);
    } catch (e) {
      if (isClosed) return; 
      emit(state + 1);
    }
  }
}
''', useExamplePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
