import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:my_lints/src/common/extensions/interface_type_extensions.dart';
import 'package:my_lints/src/common/extensions/list_extensions.dart';

extension ClassDeclarationExtensions on ClassDeclaration {
  bool get isFlutterWidget {
    final type = extendsClause?.superclass.type;
    return type is InterfaceType && type.isFlutterState;
  }

  bool get isCubitClass {
    final type = extendsClause?.superclass.type;
    return type is InterfaceType && type.isCubitLike;
  }

  bool get isEquatable {
    final type = extendsClause?.superclass.type;
    return type is InterfaceType && type.isEquatable;
  }

  /// Returns the instance field names of the class.
  Set<String> get fields => members.instanceFieldNames;

  /// Returns the list of instance fields with function types, which are considered widget callback fields.
  List<VariableDeclaration> get widgetCallbackFields {
    return members
        .whereType<FieldDeclaration>()
        .where((e) => !e.isStatic)
        .where((e) => e.fields.type?.type is FunctionType || (e.fields.type?.type?.isDartCoreFunction ?? false))
        .expand((e) => e.fields.variables)
        .toList();
  }

  /// Checks if the class is a data class.
  ///
  /// A data class is defined as a class that:
  /// - Has at least one final field
  /// - Has a copyWith method
  /// - Has at least one constructor
  bool get isDataClass {
    final fields = members.whereType<FieldDeclaration>().toList();
    if (fields.isEmpty) return false;

    final hasFinalFields = fields.any((f) => f.fields.isFinal);
    final hasCopyWith = members.whereType<MethodDeclaration>().any((m) => m.name.lexeme == 'copyWith');
    final hasConstructor = members.whereType<ConstructorDeclaration>().isNotEmpty;

    return hasFinalFields && hasConstructor && hasCopyWith;
  }
}
