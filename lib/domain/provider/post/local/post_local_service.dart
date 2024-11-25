
import 'package:connectivity_hive_bloc/config/db/db_key.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/interface/interface_provider.dart';
import 'package:connectivity_hive_bloc/domain/services/utils/logger.dart';
import 'package:hive/hive.dart';
class PostLocalService implements InterfaceProvider<Post> {
  /// Box Key
  static const String _key = DbKey.dbPost;

  /// Products Box
  late final Box<Post> _productsBox;

  PostLocalService();

  /// init DB
  Future<void> initDataBase() async {
    try {
      Hive.registerAdapter(PostAdapter());
      _productsBox = await Hive.openBox(_key);
      logger.d('Success on initializing database For *Post*');
    } catch (e) {
      // Handle initialization errors
      logger.e('Error initializing database For *ProductModel*');
    }
  }

  @override
  Future<Post?> getAll() async {
    try {
      if (_productsBox.isOpen && _productsBox.isNotEmpty) {
        return _productsBox.get(_key);
      } else {
        return null;
      }
    } catch (e) {
      // Handle read errors
      logger.e('Error reading from database: $e');
    }

    return null;
  }

  @override
  Future<void> insertItem({required Post object}) async {
    try {
      await _productsBox.put(_key, object);
    } catch (e) {
      // Handle insertion errors
      logger.e('Error inserting into database: $e');
    }
  }

  @override
  Future<bool> isDataAvailable() async {
    try {
      return _productsBox.isNotEmpty;
    } catch (e) {
      // Handle error checking box emptiness
      logger.e('Error checking if box is empty: $e');
      return true; // Return true assuming it's empty on error
    }
  }
}