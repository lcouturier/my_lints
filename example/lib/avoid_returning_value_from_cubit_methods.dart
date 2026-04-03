import 'package:flutter_bloc/flutter_bloc.dart';

class LegalCubit extends Cubit<bool> {
  LegalCubit() : super(false);

  void initialize() {
    emit(true);
  }

  bool get isInitialized => state;

  bool getState() {
    return state;
  }
}
