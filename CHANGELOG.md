## 0.0.1

### Added

* Add the `PreferLast` lint rule for detecting access to the last element of a
  collection.
* Add a quick fix for `PreferIsEmpty` to replace length comparisons with
  `isEmpty` or `isNotEmpty`.
* Add the `UseItemextentForLargeList` lint rule.

### Improved

* Expand `PreferIsEmpty` detection and improve `PreferFirst` detection for
  collection extensions.
* Improve `UseItemextentForLargeList` analysis for `ListView` widgets declared
  outside widget classes.
* Update analyzer dependencies and adapt the plugin to the newer analyzer API.

### Fixed

* Prevent incomplete `copyWith` implementations from going undetected.
* Preserve return-type nullability and type arguments in the `PreferVoidCallback`
  quick fix.
* Resolve enclosing declarations correctly with the newer analyzer API.

### Testing and CI

* Expand unit-test coverage for lint rules and quick fixes.
* Add GitHub Actions workflows for analysis, formatting, tests, and test
  coverage.
