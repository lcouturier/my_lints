extension HashJoinExtension<L> on Iterable<L> {
  Iterable<({L left, R right})> hashJoin<R, K>(Iterable<R> other, K Function(L) leftKey, K Function(R) rightKey) sync* {
    final map = <K, List<R>>{};
    for (final item in other) {
      final k = rightKey(item);
      map.putIfAbsent(k, () => []).add(item);
    }

    for (var leftValue in this) {
      final key = leftKey(leftValue);
      final rightValue = map[key];
      if (rightValue != null) {
        for (var r in rightValue) {
          yield (left: leftValue, right: r);
        }
      }
    }
  }
}
