import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'skycastle_state.dart';

class SkycastleCubit extends Cubit<SkycastleState> {
  SkycastleCubit() : super(const SkycastleState());
}
