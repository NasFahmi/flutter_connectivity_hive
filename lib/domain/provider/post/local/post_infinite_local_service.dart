import 'package:connectivity_hive_bloc/config/db/db_key.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/interface/interface_provider.dart';
import 'package:hive/hive.dart';

class PostInfiniteLocalService implements InterfaceProvider<List<Post>> {
  /// Box Key
  static const String _key = DbKey.dbPostIfinite;

  /// posts Box
  late final Box<List<Post>> _postsInfiniteBox;

  PostInfiniteLocalService();

  /// init DB local
  Future<void> initDataBase() async {
    try {
      // Hive.registerAdapter(PostAdapter());
      _postsInfiniteBox = await Hive.openBox<List<Post>>(_key);
      logger.d('Success on initializing database For *Post Infinite*');
    } catch (e) {
      // Handle initialization errors
      logger.e('Error initializing database For *post infinite* $e');
    }
  }

  // get all post from local database
  @override
  Future<List<Post>?> getAll() async {
    try {
      if (_postsInfiniteBox.isOpen && _postsInfiniteBox.isNotEmpty) {
        return _postsInfiniteBox.get(_key);
      }
      return [];
    } catch (e) {
      // Handle read errors
      logger.e('Error reading from database post infinite: $e');
      throw Exception('Error reading from database post infinite: $e');
    }

    // return [];
  }

  @override
  Future<void> clearItem() async {
    try {
      await _postsInfiniteBox.clear(); // Menghapus semua item dari box
      logger.d('Successfully cleared all items from database.');
    } catch (e) {
      // Handle clear errors
      logger.e('Error clearing items from database: $e');
    }
  }

  // delete item(opsinal)
  @override
  Future<void> deleteItem({required dynamic object}) async {
    try {
      if (_postsInfiniteBox.isOpen && _postsInfiniteBox.isNotEmpty) {
        List<Post>? posts = _postsInfiniteBox.get(_key);

        if (posts != null && object is Post) {
          // Memastikan object adalah Post
          posts.remove(object); // Menghapus item dari daftar
          await _postsInfiniteBox.put(
              _key, posts); // Memperbarui box dengan daftar yang sudah dihapus
          logger.d('Successfully deleted item from database: ${object.title}');
        } else {
          logger
              .e('No posts found in the box to delete or invalid object type.');
        }
      }
    } catch (e) {
      // Handle deletion errors
      logger.e('Error deleting item from database: $e');
    }
  }

  // insert post list to database with infinite list
  @override
  Future<void> insertItem({required List<Post> object}) async {
    try {
      if (_postsInfiniteBox.isOpen) {
        List<Post>? existingPosts = _postsInfiniteBox.get(_key) ?? [];
        // Create a new list to avoid modifying the original
        List<Post> updatedPosts = List<Post>.from(existingPosts);
        // Add new posts, avoiding duplicates
        for (Post newPost in object) {
          // Check if the post already exists (you might want to use a unique identifier)
          if (!updatedPosts.any((post) => post.id == newPost.id)) {
            updatedPosts.add(newPost);
          }
        }
        // Save the updated list back to the box
        await _postsInfiniteBox.put(_key, updatedPosts);
        logger.d(
            'Successfully inserted ${object.length} new posts. Total posts: ${updatedPosts.length}');
      } else {
        logger.e('Hive box is not open');
      }
    } catch (e) {
      logger.e('Error inserting items to database: $e');
      throw Exception('Failed to insert posts: $e');
    }
  }

  @override
  Future<bool> isDataAvailable() async {
    try {
      return _postsInfiniteBox.isNotEmpty;
    } catch (e) {
      // Handle error checking box emptiness
      logger.e('Error checking if box is empty: $e');
      return true; // Return true assuming it's empty on error
    }
  }
}
