sealed class AppState {}

class ErrorState extends AppState {
  ErrorState(this.error, this.information);

  final String error;
  final String information;
}

void logError(AppState state) {
  if (state is ErrorState) {
    print(state.error);
    print(state.information);
  }
}

void logErrorWithPattern(AppState state) {
  if (state case ErrorState(:final error, :final information)) {
    print(error);
    print(information);
  }
}
