import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

part 'favscreen_event.dart';
part 'favscreen_state.dart';

class FavscreenBloc extends Bloc<FavscreenEvent, FavscreenState> {
  FavscreenBloc({required this.repo})
      : super(const FavscreenState(
          status: StateStatus.initial,
          all: [],
          selected: {},
        )) {
    on<FavscreenStarted>(_onFavscreenStarted);
    on<FavscreenDeleted>(_onFavscreenDeleted);

    on<FavscreenSelected>((event, emit) {
      sc.closeAllOpenCell();
      Set<String> selected = {...state.selected};
      if (event.isSelected) {
        if (selected.length < 4) {
          selected.add(event.key);
        }
      } else {
        selected.remove(event.key);
      }
      emit(state.copyWith(selected: selected));
    });
  }
  Repository repo;
  SwipeActionController sc = SwipeActionController();
  Future<void> _onFavscreenStarted(FavscreenStarted event, Emitter emit) async {
    var all = await repo.favourites.getAll();

    emit(FavscreenState(
      status: StateStatus.success,
      all: all.entries
          .map((e) => FavModel(
              key: e.key,
              hero: repo.cachePersons[e.value["id_tag"]]!,
              personBuild: PersonBuild.fromJson(e.value)))
          .toList(),
      selected: const {},
    ));
  }

  Future<void> _onFavscreenDeleted(FavscreenDeleted event, Emitter emit) async {
    await repo.favourites.delFav(event.key.toString());
    List<FavModel> all = [...state.all];
    all.removeWhere((element) => element.key == event.key);
    Set<String> selected = {...state.selected};
    selected.remove(event.key);
    emit(state.copyWith(
      all: all,
      selected: selected,
    ));
  }
}
