import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<bool> {
  MyCubit(super.initialState);

  Future<void> _process() async {
    await Future.delayed(Duration(seconds: 10));
  }

  Future<void> load() async {
    emit(false);
    await _process();
    emit(true); // LINT
  }

  Future<void> loadWithCatch() async {
    emit(true);
    try {
      await _process();
      emit(true); // LINT
    } catch (e) {
      emit(false); // LINT
    }
  }
}
