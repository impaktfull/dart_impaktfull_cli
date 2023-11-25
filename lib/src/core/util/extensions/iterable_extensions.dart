extension IterableExtension<T> on Iterable<T> {
  /// Finds the first item that matches [where], if no such item could be found
  /// returns `null`
  T? find(bool Function(T) where) {
    for (final element in this) {
      if (where(element)) return element;
    }
    return null;
  }
}
