import 'package:analyzer/dart/element/type.dart';

extension RecordTypeExtensions on RecordType {
  // Checks if a record type has both positional and named fields.
  bool get isMixed => positionalFields.isNotEmpty && namedFields.isNotEmpty;
}
