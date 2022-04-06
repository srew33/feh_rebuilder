import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'skycastle_state.dart';

class SkycastleCubit extends Cubit<SkycastleState> {
  SkycastleCubit() : super(SkycastleState());
}
