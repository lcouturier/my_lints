extension HashJoinExtension<L> on Iterable<L> {
  Iterable<({L left, R right})> hashJoin<R, K>(
    Iterable<R> other, {
    K Function(L)? leftKey,
    K Function(R)? rightKey,
  }) sync* {
    final lk = leftKey ?? (e) => e as K;
    final rk = rightKey ?? (e) => e as K;

    final map = <K, List<R>>{};
    for (final item in other) {
      final k = rk(item);
      map.putIfAbsent(k, () => []).add(item);
    }

    for (var leftValue in this) {
      final key = lk(leftValue);
      final rightValue = map[key];
      if (rightValue != null) {
        for (var r in rightValue) {
          yield (left: leftValue, right: r);
        }
      }
    }
  }

  Iterable<L> intersect(Iterable<L> others, {bool unique = true}) sync* {
    final emitted = unique ? <L>{} : null;

    final s = others.toSet();
    for (final item in this) {
      if (s.contains(item) && ((emitted == null) || emitted.add(item))) {
        yield item;
      }
    }
  }
}
