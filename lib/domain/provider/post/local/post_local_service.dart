import 'package:connectivity_hive_bloc/config/db/db_key.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/interface/interface_provider.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:hive/hive.dart';

class PostLocalService implements InterfaceProvider<List<Post>> {
  /// Box Key
  static const String _key = DbKey.dbPost;

  /// posts Box
  late final Box<List<Post>> _postsBox;

  PostLocalService();

  /// init DB local
  Future<void> initDataBase() async {
    try {
      Hive.registerAdapter(PostAdapter());
      _postsBox = await Hive.openBox(_key);
      logger.d('Success on initializing database For *Post*');
    } catch (e) {
      // Handle initialization errors
      logger.e('Error initializing database For *postModel*');
    }
  }

  // get all post from local database
  @override
  Future<List<Post>?> getAll() async {
    try {
      if (_postsBox.isOpen && _postsBox.isNotEmpty) {
        return _postsBox.get(_key);
      }
      return [];
    } catch (e) {
      // Handle read errors
      logger.e('Error reading from database: $e');
      throw Exception('Error reading from database: $e');
    }

    // return [];
  }

  // insert data to database local
  @override
  Future<void> insertItem({required List<Post> object}) async {
    try {
      await _postsBox.put(_key, object);
    } catch (e) {
      // Handle insertion errors
      logger.e('Error inserting into database: $e');
    }
  }

  // checking is not empty
  @override
  Future<bool> isDataAvailable() async {
    try {
      return _postsBox.isNotEmpty;
    } catch (e) {
      // Handle error checking box emptiness
      logger.e('Error checking if box is empty: $e');
      return true; // Return true assuming it's empty on error
    }
  }

  // delete data from database local
  @override
  Future<void> deleteItem({required dynamic object}) async {
    try {
      if (_postsBox.isOpen && _postsBox.isNotEmpty) {
        List<Post>? posts = _postsBox.get(_key);

        if (posts != null && object is Post) {
          // Memastikan object adalah Post
          posts.remove(object); // Menghapus item dari daftar
          await _postsBox.put(
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

  // clear data from database local
  @override
  Future<void> clearItem() async {
    try {
      await _postsBox.clear(); // Menghapus semua item dari box
      logger.d('Successfully cleared all items from database.');
    } catch (e) {
      // Handle clear errors
      logger.e('Error clearing items from database: $e');
    }
  }
}
