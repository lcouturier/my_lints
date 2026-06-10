# My Lints

Custom lint rules using the Dart 3.11 analyzer plugin API. This package provides a comprehensive set of lints to improve code quality, readability, and maintainability in Dart and Flutter projects.

## Features

- **Custom Lint Rules**: Over 50 custom lint rules covering various aspects of Dart and Flutter development.
- **Quick Fixes**: Automated fixes for many of the reported issues.
- **Configurable**: Some rules can be tailored to your project's needs via `analysis_options.yaml`.

## Installation

Add `my_lints` to your `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  my_lints: ^0.0.1
```

## Getting Started

1. Enable the plugin in your `analysis_options.yaml`:

   ```yaml
   analyzer:
     plugins:
       - my_lints
   ```

2. (Optional) Configure specific rules:

   ```yaml
   my_lints:
     rules:
       - avoid_complicated_conditionals:
           threshold: 5
       - avoid_nested_if:
           max-nesting-level: 2
   ```

## Available Rules (Partial List)

### General Dart Lints
- `avoid_dynamic_type`: Avoid using `dynamic` to ensure type safety.
- `avoid_magic_numbers`: Avoid using magic numbers; use named constants instead.
- `prefer_explicit_function_type`: Prefer explicit function types for better readability.
- `avoid_yoda_conditions`: Avoid Yoda conditions (e.g., `if (5 == value)`).
- `avoid_double_negation_conditions`: Avoid double negations like `!!value`.

### Flutter Specific Lints
- `controller_dispose_rule`: Ensures that `ChangeNotifier` and other controllers are properly disposed.
- `avoid_context_in_initState`: Avoid using `BuildContext` in `initState`.
- `avoid_mounted_in_setstate`: Avoid checking `mounted` inside `setState`.
- `edge_insets_rule`: Encourages consistent use of `EdgeInsets`.

### Records and Spreads
- `avoid_nested_record`: Avoid deeply nested records.
- `prefer_named_record_fields`: Prefer named fields in records for clarity.
- `prefer_null_aware_spread`: Use null-aware spread operators when appropriate.

## Contributing

Contributions are welcome! If you have an idea for a new lint rule or have found a bug, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
