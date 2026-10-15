import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

bool isNullableType(DartType? type) => type?.nullabilitySuffix == NullabilitySuffix.question;

extension DartTypeNullableExtensions on DartType? {
  bool get isNullable => isNullableType(this);

  // Checks if a type is a Widget.
  bool get isWidget => this?.getDisplayString(withNullability: false) == 'Widget';

  // Checks if a type has a constructor with a given name.
  bool hasConstructor(String name) {
    return (this is InterfaceType) && (this! as InterfaceType).constructors.any((e) => e.name == name);
  }

  // Checks if a type is a callback function.
  bool get isCallbackType {
    return toString().startsWith('Null') || _isCallbackType(this);
  }

  // Checks if a DartType is a callback type.
  bool _isCallbackType(DartType? type) {
    return (type is FunctionType &&
        (type.returnType is VoidType || type.returnType is DynamicType || type.formalParameters.isEmpty));
  }

  bool get isFutureLike => this?.isDartAsyncFuture == true || this?.isDartAsyncFutureOr == true;
}
