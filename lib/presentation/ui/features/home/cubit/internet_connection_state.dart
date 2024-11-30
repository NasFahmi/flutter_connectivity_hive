part of 'internet_connection_cubit.dart';

sealed class InternetConnectionState extends Equatable {
  const InternetConnectionState();

  @override
  List<Object> get props => [];
}

final class InternetConnectionInitial extends InternetConnectionState {}

class InternetStatusConnected extends InternetConnectionState {}

class InternetStatusDisconnected extends InternetConnectionState {}