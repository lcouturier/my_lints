# Dart Lint Rules Skills

## Core Competencies

### Dart Analyzer Plugin Development
- **Analyzer Plugin API**: Mastery of Dart 3.10+ analyzer plugin API
- **AST Traversal**: Expert understanding of Abstract Syntax Tree navigation
- **Error Reporting**: Precise diagnostic error and warning generation
- **Rule Registration**: Proper registration of custom lint rules
- **Performance Optimization**: Efficient analysis without blocking IDE

### Lint Rule Design Patterns
- **Code Pattern Detection**: Identifying anti-patterns and code smells
- **Type System Analysis**: Leveraging Dart's type system for static analysis
- **Flow Analysis**: Understanding control flow and data flow
- **Scope Analysis**: Variable scope and lifecycle tracking
- **Metadata Processing**: Handling annotations and metadata

### Flutter-Specific Analysis
- **Widget Tree Analysis**: Understanding widget composition patterns
- **Build Method Optimization**: Detecting performance bottlenecks in rebuilds
- **State Management Patterns**: Identifying proper state management usage
- **Const Constructor Detection**: Enforcing const optimization
- **Asset and Resource Validation**: Analyzing asset references

## Technical Knowledge Areas

### Dart Language Specifications
- **Null Safety**: Deep understanding of sound null safety
- **Type Inference**: Knowing when types can and should be inferred
- **Async/Await Patterns**: Proper asynchronous code patterns
- **Extension Methods**: Analyzing extension usage and conflicts
- **Pattern Matching**: Dart 3 pattern matching analysis

### Code Quality Metrics
- **Cyclomatic Complexity**: Measuring and controlling complexity
- **Code Duplication**: Detecting redundant code patterns
- **Naming Conventions**: Enforcing consistent naming standards
- **Documentation Coverage**: Ensuring proper documentation
- **Test Coverage Analysis**: Identifying untested code paths

### Performance Analysis
- **Memory Allocation Patterns**: Detecting inefficient allocations
- **Collection Usage**: Optimizing list, set, and map operations
- **String Operations**: Efficient string manipulation patterns
- **Algorithmic Complexity**: Identifying O(n²) and worse patterns
- **Widget Rebuild Optimization**: Flutter-specific performance

## Rule Implementation Skills

### Rule Categories
1. **Style Rules**: Code formatting and style consistency
2. **Documentation Rules**: Public API documentation requirements
3. **Errors**: Potential runtime errors and bugs
4. **Performance**: Performance anti-patterns
5. **Best Practices**: Idiomatic Dart/Flutter patterns

### Rule Severity Levels
- **Error**: Code that will fail at runtime or break functionality
- **Warning**: Code that works but is problematic
- **Info**: Suggestions for improvement
- **Hint**: Minor style or documentation suggestions

### Rule Implementation Checklist
- [ ] Clear, descriptive error message
- [ ] Accurate location reporting (start/end position)
- [ ] Suggested fix with quick-action support
- [ ] Documentation explaining the rule
- [ ] Test cases covering positive and negative cases
- [ ] Performance impact analysis
- [ ] False positive prevention

## Testing Skills

### Unit Testing Lint Rules
- **Positive Test Cases**: Code that should trigger the rule
- **Negative Test Cases**: Code that should NOT trigger the rule
- **Edge Cases**: Boundary conditions and unusual patterns
- **Fix Verification**: Testing suggested code fixes
- **Performance Testing**: Rule execution time measurement

### Integration Testing
- **Plugin Registration**: Proper plugin initialization
- **IDE Integration**: Testing with VS Code, IntelliJ
- **Multi-file Analysis**: Cross-file rule validation
- **Partial Analysis**: Handling incremental analysis
- **Error Recovery**: Graceful handling of malformed code

## Debugging and Troubleshooting

### Common Issues
- **False Positives**: Identifying and eliminating incorrect triggers
- **Performance Bottlenecks**: Profiling slow rule execution
- **AST Parsing Errors**: Handling syntax errors gracefully
- **Scope Confusion**: Correct variable scope resolution
- **Type Resolution**: Accurate type inference in complex scenarios

### Debugging Techniques
- **AST Inspection**: Visualizing the syntax tree
- **Logging**: Strategic logging for rule execution
- **Isolation Testing**: Testing rules in isolation
- **Comparison Testing**: Comparing with built-in lints
- **IDE Integration**: Using IDE debugging tools

## Documentation Skills

### Rule Documentation
- **Purpose**: Clear explanation of why the rule exists
- **Examples**: Before/after code examples
- **Configuration**: How to enable/disable/configure
- **Related Rules**: Links to similar or complementary rules
- **References**: Links to style guides or best practices

### Package Documentation
- **Installation**: Clear setup instructions
- **Configuration**: analysis_options.yaml examples
- **Rule List**: Complete catalog with descriptions
- **Migration Guide**: Upgrading between versions
- **Contribution Guidelines**: How to add new rules

## Best Practices

### Rule Design Principles
- **Specificity**: Each rule should have a single, clear purpose
- **Actionability**: Errors should suggest concrete fixes
- **Performance**: Rules must be fast and non-blocking
- **Accuracy**: Minimize false positives and negatives
- **Consistency**: Align with Dart/Flutter conventions

### Code Review for Lint Rules
- **AST Correctness**: Ensure proper AST traversal
- **Error Quality**: Verify error messages are helpful
- **Fix Accuracy**: Test suggested fixes thoroughly
- **Documentation**: Complete and clear documentation
- **Testing**: Comprehensive test coverage

## Tooling and Environment

### Development Tools
- **Dart SDK**: Latest stable version (3.10+)
- **Analyzer Package**: analyzer ^8.0.0
- **Plugin Package**: analyzer_plugin ^0.13.0
- **Testing Framework**: flutter_test
- **IDE Support**: VS Code / IntelliJ with Dart plugin

### Build and Release
- **Pub Publishing**: Package versioning and publishing
- **Semantic Versioning**: Proper version management
- **Changelog Maintenance**: Documenting changes
- **CI/CD**: Automated testing and publishing
- **Issue Tracking**: Bug reports and feature requests

## Advanced Topics

### Custom Analysis Contexts
- **Project-specific Analysis**: Handling different project types
- **Configuration-aware Rules**: Rules that adapt to settings
- **Conditional Analysis**: Context-sensitive rule activation
- **Multi-package Analysis**: Analyzing workspace dependencies

### Experimental Features
- **Machine Learning**: AI-assisted pattern detection
- **Dynamic Rule Loading**: Runtime rule configuration
- **Remote Analysis**: Cloud-based analysis services
- **Real-time Feedback**: Instant analysis during typing

## Continuous Learning

### Keeping Current
- **Dart Language Updates**: Following Dart evolution
- **Analyzer API Changes**: Tracking API modifications
- **Community Standards**: Aligning with community practices
- **Performance Research**: New optimization techniques
- **Tooling Improvements**: Leveraging new development tools

### Knowledge Sharing
- **Open Source Contribution**: Contributing to Dart analyzer
- **Community Engagement**: Participating in discussions
- **Documentation Writing**: Sharing knowledge publicly
- **Conference Presentations**: Speaking about lint rules
- **Blog Posts**: Writing about advanced techniques
