abstract class Filter<T, N, M> {
  // set input(List<T?> data);
  List<T> input;

  N filterType;
  Filter({
    required this.input,
    required this.filterType,
  });

  List<T> get output;

  bool filtFunc(M element);
}
