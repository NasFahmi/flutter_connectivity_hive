import 'package:bloc/bloc.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/infinite_scroll/repository/postInfiniteRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'post_infinite_event.dart';
part 'post_infinite_state.dart';

class PostInfiniteBloc extends Bloc<PostInfiniteEvent, PostInfiniteState> {
  final PostInfiniteRepository repository;
  
  // Pagination parameters
  int _page = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;

  PostInfiniteBloc({required this.repository}) 
      : super(PostInfiniteInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
  }

  void _onFetchPosts(
    FetchPostsEvent event, 
    Emitter<PostInfiniteState> emit
  ) async {
    if (state.hasReachedMax) return;

    try {
      if (state is PostInfiniteInitial) {
        // ketika pertama kali terload
        final posts = await repository.getPostWithLimit(0, _limit);
        logger.d('post initial fetching : $posts with page : $_page and limit : $_limit');
        emit(PostInfiniteLoaded(
          posts: posts, 
          hasReachedMax: posts.length < _limit
        ));
        _page++;
      } else if (state is PostInfiniteLoaded) {
        // ketika bukan pertama kali terload
        final currentState = state as PostInfiniteLoaded;
        final newPosts = await repository.getPostWithLimit(_page * _limit, _limit);

        if (newPosts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          _page++;
          emit(PostInfiniteLoaded(
            posts: List.of(currentState.posts)..addAll(newPosts),
            hasReachedMax: newPosts.length < _limit
          ));
        }
      }
    } catch (e) {
      emit(PostInfiniteError(message: e.toString()));
    }
  }

  void _onRefreshPosts(
    RefreshPostsEvent event, 
    Emitter<PostInfiniteState> emit
  ) async {
    // Reset pagination
    _page = 0;
    _hasReachedMax = false;

    try {
      final posts = await repository.getPostWithLimit(0, _limit);
      
      emit(PostInfiniteLoaded(
        posts: posts, 
        hasReachedMax: posts.length < _limit
      ));
      _page++;
    } catch (e) {
      emit(PostInfiniteError(message: e.toString()));
    }
  }
}