import '../filters/filter.dart';

class FilterChain<T, N, M> {
  List<T> input;
  // List output = [];
  List<Filter<T, N, M>> filters;

  // SameTypeMode mode;

  FilterChain({required this.input, required this.filters});

  void add(Filter<T, N, M> filter) {
    filters.add(filter);
  }

  void removeAt(int index) {
    filters.removeAt(index);
  }

  void remove(Filter filter) {
    filters.remove(filter);
  }

  List<T?> get output {
    List<T?> out = input;
    for (Filter<T?, N, M> filter in filters) {
      filter.input = out;
      out = filter.output;
    }

    return out;
  }
}
