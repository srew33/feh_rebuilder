import 'package:flutter_bloc/flutter_bloc.dart';

class ScreensCubit extends Cubit<int> {
  ScreensCubit() : super(0);

  void changeScreen(int index) {
    emit(index);
  }
}
