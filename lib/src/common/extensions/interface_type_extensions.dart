import 'package:analyzer/dart/element/type.dart';

extension InterfaceTypeExtensions on InterfaceType {
  bool get isFlutterState {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((t) {
      final element = t.element;

      return (element.name == 'State' || element.name == 'StatelessWidget' || element.name == 'StatefulWidget') &&
          element.library.firstFragment.source.uri.toString().contains('framework');
    });
  }

  bool get isCubitLike {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((t) {
      final element = t.element;
      return element.name == 'Cubit' && element.library.firstFragment.source.uri.toString().contains('bloc');
    });
  }

  bool get isEquatable {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((t) {
      final element = t.element;
      return element.name == 'Equatable' && element.library.firstFragment.source.uri.toString().contains('equatable');
    });
  }

  bool get isStreamSubscription {
    final allTypes = [this, ...allSupertypes];

    return allTypes.any((e) {
      final element = e.element;
      return element.name == 'StreamSubscription' &&
          element.library.firstFragment.source.uri.toString().contains('dart:async');
    });
  }
}
