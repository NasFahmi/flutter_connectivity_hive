part of 'post_infinite_bloc.dart';

sealed class PostInfiniteEvent extends Equatable {
  const PostInfiniteEvent();

  @override
  List<Object> get props => [];
}
class FetchPostsEvent extends PostInfiniteEvent {}

class RefreshPostsEvent extends PostInfiniteEvent {}