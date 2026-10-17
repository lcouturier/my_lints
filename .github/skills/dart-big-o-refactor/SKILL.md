---
name: dart-big-o-refactor
description: Identify methods and functions with high Big O time/space complexity in Dart code and refactor them for better performance. Use when reviewing Dart or Flutter code for performance bottlenecks, algorithmic efficiency, nested loops, or high computational complexity.
---

# Dart Big O Refactoring

A guide to identifying and refactoring Dart code with high Big O complexity (such as $O(N^2)$, $O(N^3)$, inefficient recursions, or hidden list scans) to optimize runtime performance and prevent UI jank in Flutter applications.

## When to Use

- Reviewing Dart or Flutter codebases for algorithmic performance bottlenecks.
- Analyzing nested loops, collection filtering methods, and recursive algorithms.
- Refactoring inefficient time or space complexity into optimal solutions ($O(N \log N)$ or $O(N)$).

## Analysis Workflow

1. **Detect Complexity Anti-Patterns:**
   - **Nested Loops:** Look for `for`, `while`, or `.forEach()` loops nested inside one another.
   - **Hidden $O(N)$ inside Loops:** Calling methods like `.contains()`, `.firstWhere()`, `.indexWhere()`, or `.removeWhere()` on `List` inside a loop, resulting in an inadvertent $O(N^2)$ runtime.
   - **Unmemoized Recursion:** Identifying recursive functions that recompute identical subproblems (exponential $O(2^N)$ time complexity).

2. **Refactoring Strategies:**
   - **Use Hash-Based Lookups:** Convert lookup lists into `Set` or `Map` before iterating, dropping lookup time from $O(N)$ to $O(1)$.
   - **Memoization & Caching:** Store computed results in a local cache or map during recursion.
   - **Single-Pass Algorithms:** Aggregate data in a single pass using accumulators or maps rather than multiple sequential filtering passes.

## Code Examples

### Anti-Pattern ($O(N^2)$ due to list `.contains()`)

```dart
List<String> findCommon(List<String> listA, List<String> listB) {
  // listB.contains is O(N) inside O(N) loop -> O(N^2) total
  return listA.where((item) => listB.contains(item)).toList();
}
```
