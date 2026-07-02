import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/type_checker.dart';

class AvoidI18nCurrentFix extends ResolvedCorrectionProducer with ContextName {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidI18nCurrent',
    DartFixKindPriority.standard,
    'Replace I18n.current with I18n.of(context)...',
  );

  static const String badWay = 'I18n.current.';

  AvoidI18nCurrentFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    )) {
      final (hasFix, paramName) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      final replacement = 'I18n.of($paramName)';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(node), replacement);
      });
    }

    if (node case PrefixedIdentifier(
      prefix: SimpleIdentifier(name: 'I18n'),
      identifier: SimpleIdentifier(name: 'current'),
    )) {
      final (hasFix, paramName) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      final replacement = 'I18n.of($paramName)';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(node), replacement);
      });
    }
  }
}

mixin ContextName {
  (bool, String) getContextName(MethodDeclaration? Function() getMethod, FunctionDeclaration? Function() getFunction) {
    final method = getMethod();

    if (method != null) {
      final parameters = method.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');

      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    final function = getFunction();
    if (function != null) {
      final parameters = function.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');
      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    return (false, '');
  }
}

extension FormalParameterExtensions on FormalParameter {
  bool get isBuildContext =>
      this is SimpleFormalParameter &&
      (this as SimpleFormalParameter).type != null &&
      (this as SimpleFormalParameter).type.toString() == 'BuildContext';
}

class AvoidI18nCurrentFixInFile extends ResolvedCorrectionProducer with ContextName {
  static const _fixKind = FixKind(
    'my_lints.fix.avoidI18nCurrentInFile',
    DartFixKindPriority.inFile,
    'Replace all I18n.current with I18n.of(context) in file...',
  );

  AvoidI18nCurrentFixInFile({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final visitor = _I18nCurrentVisitor();
    unit.accept(visitor);

    if (visitor.occurrences.isEmpty) return;

    await builder.addDartFileEdit(file, (builder) {
      for (final occurrence in visitor.occurrences) {
        builder.addSimpleReplacement(range.node(occurrence.$1), 'I18n.of(${occurrence.$2})');
      }
    });
  }
}

class _I18nCurrentVisitor extends RecursiveAstVisitor<void> with ContextName {
  final List<(AstNode, String)> occurrences = [];
  final Map<AstNode, (bool, String)> _contextCache = {};

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.target case PropertyAccess(
      target: SimpleIdentifier(name: 'I18n'),
      propertyName: SimpleIdentifier(name: 'current'),
    )) {
      final (hasFix, paramName) = _getCachedContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );
      if (hasFix) {
        occurrences.add((node, paramName));
      }
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'I18n' && node.identifier.name == 'current') {
      final (hasFix, paramName) = _getCachedContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );
      if (hasFix) {
        occurrences.add((node, paramName));
      }
    }
    super.visitPrefixedIdentifier(node);
  }

  (bool, String) _getCachedContextName(
    MethodDeclaration? Function() getMethod,
    FunctionDeclaration? Function() getFunction,
  ) {
    final method = getMethod();
    if (method != null) {
      return _contextCache.putIfAbsent(method, () => getContextName(getMethod, getFunction));
    }

    final function = getFunction();
    if (function != null) {
      return _contextCache.putIfAbsent(function, () => getContextName(getMethod, getFunction));
    }

    return (false, '');
  }
}
