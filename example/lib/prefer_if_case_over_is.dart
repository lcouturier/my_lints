sealed class AppState {}

class ErrorState extends AppState {
  ErrorState(this.error);

  final String error;
}

void logError(AppState state) {
  if (state is ErrorState) {
    print(state.error);
  }
}

void logErrorWithPattern(AppState state) {
  if (state case ErrorState(:final error)) {
    print(error);
  }
}
