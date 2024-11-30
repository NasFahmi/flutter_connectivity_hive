import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_service.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';

class PostLocalProvider {
  // Local Source For Home
  final PostLocalService _postLocalService;

  PostLocalProvider({
    required PostLocalService postLocalService,
  }) : _postLocalService = postLocalService;

  /// Read From DB
  Future<List<Post>?> getPosts() async {
    try {
      return await _postLocalService.getAll();
    } catch (e) {
      // Log or handle the error appropriately
      logger.e('Error retrieving categories: $e');
      return [];
    }
  }

  /// Insert To DB
  Future<void> insertPost({required List<Post> data}) async {
    try {
      await _postLocalService.insertItem(object: data);
    } catch (e) {
      // Handle insertion errors
      logger.e('Error inserting Products: $e');
    }
  }

  /// Is Data Available
  Future<bool> isPostDataAvailable() async {
    return await _postLocalService.isDataAvailable();
  }
}