part of 'post_infinite_bloc.dart';

sealed class PostInfiniteState extends Equatable {
  final bool hasReachedMax;

  
  const PostInfiniteState({this.hasReachedMax = false});

  @override
  List<Object> get props => [hasReachedMax];
}

class PostInfiniteInitial extends PostInfiniteState {}

class PostInfiniteLoaded extends PostInfiniteState {
  final List<Post> posts;

  const PostInfiniteLoaded({
    required this.posts, 
    bool hasReachedMax = false
  }) : super(hasReachedMax: hasReachedMax);

  PostInfiniteLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostInfiniteLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax];
}

class PostInfiniteError extends PostInfiniteState {
  final String message;

  const PostInfiniteError({required this.message});

  @override
  List<Object> get props => [message];
}