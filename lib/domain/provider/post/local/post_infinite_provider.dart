import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_infinite_local_service.dart';

class PostInfiniteProvider {
  final PostInfiniteLocalService _postInfiniteLocalService;
  PostInfiniteProvider({
    required PostInfiniteLocalService PostInfiniteLocalService,
  }) : _postInfiniteLocalService = PostInfiniteLocalService;


  /// Read From DB
  Future<List<Post>?> getPosts() async {
    try {
      return await _postInfiniteLocalService.getAll();
    } catch (e) {
      // Log or handle the error appropriately
      logger.e('Error retrieving categories: $e');
      return [];
    }
  }

  Future<void> fetchAndStoreNewPost(List<Post> posts) async {
    try {
      await _postInfiniteLocalService.insertItem(object: posts);
    } catch (e) {
      logger.e('Error inserting Products: $e');
    }
  }

  /// Is Data Available
  Future<bool> isPostDataAvailable() async {
    return await _postInfiniteLocalService.isDataAvailable();
  }
}
