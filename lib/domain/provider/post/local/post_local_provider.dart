import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_service.dart';
import 'package:connectivity_hive_bloc/domain/services/utils/logger.dart';

class PostLocalProvider {
  // Local Source For Home
  final PostLocalService _postLocalService;

  PostLocalProvider({
    required PostLocalService homeDataBaseService,
  }) : _postLocalService = homeDataBaseService;

  /// Read From DB
  Future<Post?> getPosts() async {
    try {
      return await _postLocalService.getAll();
    } catch (e) {
      // Log or handle the error appropriately
      logger.e('Error retrieving categories: $e');
      return null;
    }
  }

  /// Insert To DB
  Future<void> insertPost({required Post data}) async {
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