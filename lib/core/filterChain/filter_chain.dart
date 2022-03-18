import '../filters/filter.dart';

class FilterChain<T, N> {
  List<T> input;
  // List output = [];
  List<Filter<T, N>> filters;

  // SameTypeMode mode;

  FilterChain({required this.input, required this.filters});

  void add(Filter<T, N> filter) {
    filters.add(filter);
  }

  void removeAt(int index) {
    filters.removeAt(index);
  }

  void remove(Filter filter) {
    filters.remove(filter);
  }

  List<T> get output {
    List<T> out = input;
    for (Filter<T, N> filter in filters) {
      filter.input = out;
      out = filter.output;
    }

    return out;
  }
}
