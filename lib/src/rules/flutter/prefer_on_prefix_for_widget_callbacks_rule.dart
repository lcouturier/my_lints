import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:my_lints/src/common/extensions.dart';

/// A rule that requires public callback fields on Flutter widgets to start with `on`.
///
/// This rule checks instance fields with function types declared in Flutter
/// widget classes. Prefixing callback names with `on` makes their purpose clear.
///
/// ## Example
///
/// ❌ Bad:
/// ```dart
/// class SaveButton extends StatelessWidget {
///   final VoidCallback save;
/// }
/// ```
///
/// ✅ Good:
/// ```dart
/// class SaveButton extends StatelessWidget {
///   final VoidCallback onSave;
/// }
/// ```
class PreferOnPrefixForWidgetCallbacksRule extends AnalysisRule {
  PreferOnPrefixForWidgetCallbacksRule() : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'prefer_on_prefix_for_widget_callbacks',
    'Name widget callback fields with the `on` prefix.',
    correctionMessage: 'Prefix the callback field name with `on`.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferOnPrefixForWidgetCallbacksRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node case ClassDeclaration(isFlutterWidget: true, :final widgetCallbackFields)) {
      for (final field in widgetCallbackFields) {
        final name = field.name.lexeme;
        if (!name.startsWith('_') && !name.startsWith('on')) {
          rule.reportAtToken(field.name);
        }
      }
    }
  }
}
