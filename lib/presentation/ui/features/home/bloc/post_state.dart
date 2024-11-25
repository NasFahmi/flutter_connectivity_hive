part of 'post_bloc.dart';

sealed class PostState extends Equatable {
  const PostState();
  
  @override
  List<Object> get props => [];
}

final class PostInitial extends PostState {}
final class PostLoading extends PostState {}
final class PostLoaded extends PostState {
  final Post posts;
  PostLoaded({required this.posts});
}
final class PostError extends PostState {
  String error;
  PostError({required this.error});
}
