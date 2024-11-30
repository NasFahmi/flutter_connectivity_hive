import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_provider.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/remote/post_remote_provider.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';

class PostRepository {
  final PostRemoteProvider _postRemoteProvider;
  final PostLocalProvider _postLocalProvider;

  PostRepository(this._postRemoteProvider, this._postLocalProvider);

  Future<List<Post>> getPost() async {
    // checing internet connection
    final bool isInternetConnected =
        await di<InternetConnectionServices>().checkInternetConnection();

    logger.d('PostRepository : status internet is $isInternetConnected');

    // checking if data is available or not empty in local storage
    final bool isDataBaseLocalNotEmpty =
        await _postLocalProvider.isPostDataAvailable();
    logger.d('isDataBaseLocalNotEmpty $isDataBaseLocalNotEmpty');

    if (isInternetConnected) {
      try {
        final List<Post> response = await _postRemoteProvider.fetchAllPosts();
        logger.d(
            'Fetch [Post] from the Server and cache it in the local DataBase');

        if (response.isNotEmpty) {
          logger.d('Inserting data to local database');
          await _postLocalProvider.insertPost(data: response);
          logger.d('Return data from local database');
          return response; // Kembalikan data yang baru dimuat
        } else {
          return _loadLocalPost(isDataBaseLocalNotEmpty);
        }
      } catch (e) {
        logger.e('Error fetching posts: ${e.toString()}');
        return _loadLocalPost(isDataBaseLocalNotEmpty);
      }
    } else {
      return _loadLocalPost(isDataBaseLocalNotEmpty);
    }
  }

  Future<List<Post>> _loadLocalPost(bool isDataBaseLocalNotEmpty) async {
    if (isDataBaseLocalNotEmpty) {
      logger.d('Load [Post] from Local DataBase');
      List<Post>? localPostData = await _postLocalProvider.getPosts();
      if (localPostData!.isNotEmpty) {
        return localPostData;
      }
      throw Exception('No Network Connection and Local Database is Empty!');
    } else {
      throw Exception('No Network Connection and Local Database is Empty!');
    }
  }
}