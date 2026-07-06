import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/common/helpers.dart';
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
    if (_isI18nCurrent(node)) {
      final (hasContext, paramName) = _getContextName(node);
      if (!hasContext) return;

      final replacement = 'I18n.of($paramName)';
      await builder.addDartFileEdit(file, (builder) {
        builder.addSimpleReplacement(range.node(node), replacement);
      });
    }
  }

  bool _isI18nCurrent(AstNode node) => switch (node) {
    PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    ) ||
    PrefixedIdentifier(prefix: SimpleIdentifier(name: 'I18n'), identifier: SimpleIdentifier(name: 'current')) => true,
    _ => false,
  };

  (bool, String) _getContextName(AstNode node) {
    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method != null) {
      final parameters = method.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');

      final result = parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
      return result;
    }
    final function = node.thisOrAncestorOfType<FunctionDeclaration>();
    if (function != null) {
      final parameters = function.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');

      final result = parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
      return result;
    }
    return (false, '');
  }
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

class _I18nCurrentVisitor extends RecursiveAstVisitor<void> {
  final Map<AstNode, (bool, String)> _contextCache = {};
  final List<(AstNode, String)> occurrences = [];

  _I18nCurrentVisitor();

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node case PropertyAccess(
      target: PropertyAccess(target: SimpleIdentifier(name: 'I18n'), propertyName: SimpleIdentifier(name: 'current')),
    )) {
      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method is MethodDeclaration) {
        final result = _getCachedContextName(method);
        if (result.$1) {
          occurrences.add((node, result.$2));
        }
      }

      final function = node.thisOrAncestorOfType<FunctionDeclaration>();
      if (function is FunctionDeclaration) {
        final result = _getCachedContextName(function);
        if (result.$1) {
          occurrences.add((node, result.$2));
        }
      }
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node case PrefixedIdentifier(
      prefix: SimpleIdentifier(name: 'I18n'),
      identifier: SimpleIdentifier(name: 'current'),
    )) {
      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method is MethodDeclaration) {
        final result = _getCachedContextName(method);
        if (result.$1) {
          occurrences.add((node, result.$2));
        }
      }

      final function = node.thisOrAncestorOfType<FunctionDeclaration>();
      if (function is FunctionDeclaration) {
        final result = _getCachedContextName(function);
        if (result.$1) {
          occurrences.add((node, result.$2));
        }
      }
    }
    super.visitPrefixedIdentifier(node);
  }

  (bool, String) _getCachedContextName(AstNode parent) {
    return _contextCache.putIfAbsent(parent, () {
      if (parent is MethodDeclaration) {
        final parameters = parent.parameters?.parameters;
        if (parameters == null || parameters.isEmpty) return (false, '');

        final result = parameters.firstWhereOrElse(
          (e) => e.isBuildContext,
          (e) => (true, e.toString().split(' ')[1]),
          () => (false, ''),
        );
        return result;
      }
      if (parent is FunctionDeclaration) {
        final parameters = parent.functionExpression.parameters?.parameters;
        if (parameters == null || parameters.isEmpty) return (false, '');

        final result = parameters.firstWhereOrElse(
          (e) => e.isBuildContext,
          (e) => (true, e.toString().split(' ')[1]),
          () => (false, ''),
        );
        return result;
      }
      return (false, '');
    });
  }
}
