import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';

class PreferVoidCallbackRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_void_callback',
    'Prefer VoidCallback over void Function()',
    severity: DiagnosticSeverity.WARNING,
  );

  PreferVoidCallbackRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addGenericFunctionType(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferVoidCallbackRule rule;

  _Visitor(this.rule);

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    if (node.isReplaceableByCallbackAlias) {
      rule.reportAtNode(node);
    }
  }
}

extension GenericFunctionTypeExtension on GenericFunctionType {
  /// Whether this type can be replaced by `VoidCallback` or `ValueGetter`.
  ///
  /// Type aliases are the declaration site of the alias itself, and `Future`
  /// returns have no callback alias, so neither has an available fix.
  bool get isReplaceableByCallbackAlias => switch (this) {
    GenericFunctionType(parent: GenericTypeAlias()) => false,
    GenericFunctionType(returnType: NamedType(name: Token(lexeme: 'Future'))) => false,
    GenericFunctionType(typeParameters: null, parameters: FormalParameterList(parameters: [])) => true,
    _ => false,
  };
}
