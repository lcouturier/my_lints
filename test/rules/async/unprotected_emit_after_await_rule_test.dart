import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/unprotected_emit_after_await_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UnProtectedEmitAfterAwaitRule', () {
    //     test('reports emit() after await without guard in Cubit', () async {
    //       final unit = await resolveSource('''
    // import 'package:flutter_bloc/flutter_bloc.dart';

    // class MyCubit extends Cubit<int> {
    //   MyCubit() : super(0);

    //   Future<void> increment() async {
    //     await Future.delayed(Duration(seconds: 1));
    //     emit(state + 1);
    //   }
    // }
    // ''', useWorkspacePackages: true);

    //       final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

    //       expect(diagnostics, hasLength(1));
    //     });

    test('does not report emit() after await with isClosed guard', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (!isClosed) emit(state + 1);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report emit() after await with isClosed return guard', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (isClosed) return;
    emit(state + 1);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report emit() without await', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  void increment() {
    emit(state + 1);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report emit() in non-Cubit class', () async {
      final unit = await resolveSource('''
class NotACubit {
  Future<void> someMethod() async {
    await Future.delayed(Duration(seconds: 1));
    emit('something');
  }

  void emit(String value) {
    print(value);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    //     test('reports emit() in catch block without guard after await in try', () async {
    //       final unit = await resolveSource('''
    // import 'package:flutter_bloc/flutter_bloc.dart';

    // class MyCubit extends Cubit<int> {
    //   MyCubit() : super(0);

    //   Future<void> increment() async {
    //     try {
    //       await Future.delayed(Duration(seconds: 1));
    //     } catch (e) {
    //       emit(state + 1);
    //     }
    //   }
    // }
    // ''', useWorkspacePackages: true);

    //       final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

    //       expect(diagnostics, hasLength(1));
    //     });

    test('does not report emit() in catch block with guard after await in try', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      if (!isClosed) emit(state + 1);
    }
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports emit() in finally block without guard after await in try', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      await Future.delayed(Duration(seconds: 1));
    } finally {
      emit(state + 1);
    }
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report emit() in finally block with guard after await in try', () async {
      final unit = await resolveSource('''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  Future<void> increment() async {
    try {
      await Future.delayed(Duration(seconds: 1));
    } finally {
      if (!isClosed) emit(state + 1);
    }
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

      expect(diagnostics, isEmpty);
    });

    //     test('reports multiple unprotected emit() calls after await', () async {
    //       final unit = await resolveSource('''
    // import 'package:flutter_bloc/flutter_bloc.dart';

    // class MyCubit extends Cubit<int> {
    //   MyCubit() : super(0);

    //   Future<void> increment() async {
    //     await Future.delayed(Duration(seconds: 1));
    //     emit(state + 1);
    //     emit(state + 2);
    //   }
    // }
    // ''', useWorkspacePackages: true);

    //       final diagnostics = runAnalysisRuleOnUnit(UnProtectedEmitAfterAwaitRule(), unit);

    //       expect(diagnostics, hasLength(2));
    //     });
  });
}
