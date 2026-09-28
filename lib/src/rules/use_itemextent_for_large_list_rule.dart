import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class UseItemextentForLargeListRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'use_itemextent_for_large_list',
    'Use itemExtent for large lists.',
    correctionMessage: 'Add itemExtent or prototypeItem to ListView.builder for better performance',
  );

  UseItemextentForLargeListRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final UseItemextentForLargeListRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.isListViewMissingExtent) {
      rule.reportAtNode(node);
    }
  }
}

extension ListViewInstanceCreationExtension on InstanceCreationExpression {
  /// Whether this is a `ListView` laying out children without a known extent.
  bool get isListViewMissingExtent {
    if (this case InstanceCreationExpression(
      constructorName: ConstructorName(
        type: NamedType(name: Token(lexeme: 'ListView')),
        name: SimpleIdentifier(token: Token(lexeme: 'builder')) || null,
      ),
      argumentList: ArgumentList(:final arguments),
    )) {
      return !arguments.any(
        (arg) => arg is NamedExpression && const {'itemExtent', 'prototypeItem'}.contains(arg.name.label.name),
      );
    }

    return false;
  }
}
