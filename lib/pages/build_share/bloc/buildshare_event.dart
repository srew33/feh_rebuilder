part of 'buildshare_bloc.dart';

abstract class BuildshareEvent extends Equatable {
  const BuildshareEvent();

  @override
  List<Object> get props => [];
}

class BuildshareStarted extends BuildshareEvent {}

class BuildshareDeleted extends BuildshareEvent {
  final String objectId;
  const BuildshareDeleted({
    required this.objectId,
  });
}

class BuildshareLiked extends BuildshareEvent {
  final String objectId;
  final int newCount;
  const BuildshareLiked({
    required this.objectId,
    required this.newCount,
  });
}
