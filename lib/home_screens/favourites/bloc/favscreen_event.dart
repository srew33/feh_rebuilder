part of 'favscreen_bloc.dart';

abstract class FavscreenEvent extends Equatable {
  const FavscreenEvent();

  @override
  List<Object> get props => [];
}

class FavscreenStarted extends FavscreenEvent {}

class FavscreenSelected extends FavscreenEvent {
  final String key;
  final bool isSelected;

  const FavscreenSelected({required this.key, required this.isSelected});
}

class FavscreenDeleted extends FavscreenEvent {
  final String key;

  const FavscreenDeleted({
    required this.key,
  });
}
