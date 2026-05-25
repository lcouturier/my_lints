// for (final key in map.keys) {
//   print(map[key]);
// }

// for (final entry in map.entries) {
//   print(entry.value);
// }

/// In Progress

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PreferMapOverMapIndexedRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_map_over_map_indexed',
    'Prefer using map.entries instead of map.keys with map[key].',
    correctionMessage: 'Try using map.entries instead of map.keys with map[key].',
  );

  PreferMapOverMapIndexedRule() : super(name: code.name, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addForStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferMapOverMapIndexedRule rule;

  _Visitor(this.rule);

  @override
  void visitForStatement(ForStatement node) {
    if (node.forLoopParts case ForEachPartsWithIdentifier(
      iterable: Identifier(name: final mapName),
      identifier: final keyVar,
    )) {
      final body = node.body;
      if (body is Block) {
        for (final statement in body.statements) {
          if (statement case ExpressionStatement(
            expression: MethodInvocation(
              argumentList: ArgumentList(
                arguments: [
                  IndexExpression(target: SimpleIdentifier(name: final m), index: SimpleIdentifier(name: final k)),
                ],
              ),
            ),
          ) when mapName == m && keyVar.name == k) {
            rule.reportAtNode(node);
            break;
          }
        }
      }
    }
  }
}
