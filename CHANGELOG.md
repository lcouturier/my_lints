# my_lints

## 0.0.1

### Added

* Add the `avoid_uncancelled_timers_in_state` lint rule for timers stored in
  Flutter `State` fields but not cancelled in `dispose()`.
* Add the `avoid_unclosed_stream_subscriptions` lint rule for subscriptions
  stored in Flutter `State` fields but not cancelled in `dispose()`.
* Add the `avoid_get_prefix_for_properties` lint rule for property names with a `get` prefix.
* Add the `prefer_on_prefix_for_widget_callbacks` lint rule for callback fields
  declared by Flutter widgets.
* Add the `PreferLast` lint rule for detecting access to the last element of a
  collection.
* Add a quick fix for `PreferIsEmpty` to replace length comparisons with
  `isEmpty` or `isNotEmpty`.
* Add the `UseItemextentForLargeList` lint rule.
* Add the `AvoidUncheckedStreamSubscriptions` lint rule for detecting stream
  subscriptions that are not stored or cancelled.
* Add the `PreferValueNotifierOverStateful` lint rule for detecting simple
  StatefulWidget that could be replaced with ValueNotifier.

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
