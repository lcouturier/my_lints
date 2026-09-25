import 'package:flutter_bloc/flutter_bloc.dart';

class Legal extends Cubit<bool> {
  Legal() : super(false);

  void initialize() {
    emit(true);
  }

  bool get isInitialized => state;

  bool getState() {
    return state;
  }
}
