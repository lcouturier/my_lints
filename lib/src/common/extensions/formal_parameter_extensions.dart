import 'package:analyzer/dart/ast/ast.dart';

extension FormalParameterExtension on FormalParameter {
  // Checks if a formal parameter is a boolean.
  bool get isBool =>
      this is SimpleFormalParameter && ((this as SimpleFormalParameter).type?.type?.isDartCoreBool ?? false);

  bool get isBuildContext =>
      this is SimpleFormalParameter &&
      (this as SimpleFormalParameter).type != null &&
      (this as SimpleFormalParameter).type?.type?.getDisplayString(withNullability: false) == 'BuildContext';

  /// Unwraps [DefaultFormalParameter] to get the underlying parameter.
  /// This is necessary because [DefaultFormalParameter] can wrap another parameter, and we want to analyze the actual parameter type.
  /// If the parameter is not a [DefaultFormalParameter], it returns itself.
  FormalParameter get unWrapped => switch (this) {
    DefaultFormalParameter(:final parameter) => parameter,
    _ => this,
  };
}
