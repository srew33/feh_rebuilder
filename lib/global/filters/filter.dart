abstract class Filter<T, N> {
  // set input(List<T?> data);
  late List<T> input;

  late N filterType;

  List<T> get output;

  bool filtFunc(T element);
}

// class F<E> implements Filter<E> {
//   List<E> _input = [];

//   @override
//   List<E> get output {
//     List<E> output = [];

//     for (E t in input) {
//       if (filtFunc(t)) {
//         output.add(t);
//       }
//     }
//     return output;
//   }

//   List<E> get input => _input;

//   @override
//   set input(List<E> data) {
//     _input = data;
//   }

//   @override
//   bool filtFunc(element) {
//     print(element);
//     return true;
//   }
// }

// void main(List<String> args) {
//   F<int?> f = F();
//   f.input = <int>[1, 2, 3];
//   f.output;
// }
