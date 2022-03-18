import 'package:bloc/bloc.dart';

class ScreensCubit extends Cubit<int> {
  ScreensCubit() : super(0);

  void changeScreen(int index) {
    emit(index);
  }
}
