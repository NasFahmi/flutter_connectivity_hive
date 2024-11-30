import 'package:bloc/bloc.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/repository/post_repository.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  PostBloc(this._postRepository) : super(PostInitial()) {
    on<PostEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<FetchingAllPost>((event, emit)async {
      emit(PostLoading());
      try {
        final response = await _postRepository.getPost();
        if (response.isEmpty) {
          emit(PostError(error: 'No data found'));  
        }
        emit(PostLoaded(posts: response));
      } catch (e) {
        emit(PostError(error: e.toString()));
      }
    });
  }
}
