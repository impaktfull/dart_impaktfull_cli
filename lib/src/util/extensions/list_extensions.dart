extension ListExtensions<T> on List<T> {
  void sortBy<R>(Comparable<R>? Function(T item) by, {bool ascending = true}) {
    sort((a, b) {
      final byA = by(a);
      final byB = by(b);
      if (byA == null) return ascending ? -1 : 1;
      if (byB == null) return ascending ? 1 : -1;
      return _compareValues(byA, byB, ascending);
    });
  }
}

int _compareValues<T extends Comparable<dynamic>>(T a, T b, bool ascending) {
  if (identical(a, b)) return 0;
  if (ascending) return a.compareTo(b);
  return -a.compareTo(b);
}
