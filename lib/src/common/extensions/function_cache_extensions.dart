extension FunctionCacheExtensions<F, R> on R Function(F) {
  // Caches the results of a function call.
  R Function(F) cache() {
    final cache = <F, R>{};
    return (key) => cache.putIfAbsent(key, () => this(key));
  }
}
