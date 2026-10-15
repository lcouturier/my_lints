import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:my_lints/src/common/extensions/function_cache_extensions.dart';
import 'package:my_lints/src/common/extensions/interface_type_extensions.dart';

extension DartTypeExtensions on DartType {
  /// Returns true if the type is a list or set.
  ///
  /// This includes:
  /// - `Iterable`
  /// - `Set`
  /// - `List`
  /// - `Map`
  ///
  /// Note: `Map` is included because it can be spread in map literals.
  bool get isListOrSet => isDartCoreIterable || isDartCoreSet || isDartCoreList || isDartCoreMap;

  // Checks if a DartType is a nullable list.
  bool get isNullableList {
    final predicates = [
      () => this is InterfaceType,
      () => element?.name == 'List',
      () => nullabilitySuffix == NullabilitySuffix.question,
    ];

    return predicates.every((e) => e());
  }

  // Checks if a DartType is a subtype of a given type name.
  bool _isSubtypeOfType(String typeName) {
    return element?.displayName == typeName ||
        ((this is InterfaceType) && (this as InterfaceType).allSupertypes.any((e) => e.element.name == typeName));
  }

  // Returns a cached version of the `_isSubtypeOfType` method.
  bool Function(String) get isSubtypeOfType => _isSubtypeOfType.cache();

  bool shouldBeDisposed() {
    if (this is! InterfaceType) return false;
    final element = (this as InterfaceType).element;
    return element.lookUpMethod(name: 'dispose', library: element.library) != null;
  }

  bool get isDisposable => shouldBeDisposed();

  bool get isFutureVoid {
    return switch (this) {
      InterfaceType(element: InterfaceElement(name: 'Future'), typeArguments: [VoidType()]) => true,
      _ => false,
    };
  }

  bool get isStreamSubscription => (this is InterfaceType) && (this as InterfaceType).isStreamSubscription;
}
