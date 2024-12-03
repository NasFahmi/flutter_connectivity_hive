import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_infinite_local_service.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_infinite_provider.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/remote/post_remote_provider.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';

class PostInfiniteRepository {
  final PostRemoteProvider _postRemoteProvider;
  final PostInfiniteProvider _postInfiniteProvider;
  PostInfiniteRepository(this._postRemoteProvider, this._postInfiniteProvider);
  Future<List<Post>> _loadLocalPost(bool isDataBaseLocalNotEmpty) async {
    if (isDataBaseLocalNotEmpty) {
      logger.d('Load [Post] from Local DataBase');
      List<Post>? localPostData = await _postInfiniteProvider.getPosts();
      if (localPostData!.isNotEmpty) {
        return localPostData;
      }
      throw Exception('No Network Connection and Local Database is Empty!');
    } else {
      throw Exception('No Network Connection and Local Database is Empty!');
    }
  }

  Future<List<Post>> getPostWithLimit(int start, int limit) async {
    // checing internet connection
    final bool isInternetConnected =
        await di<InternetConnectionServices>().checkInternetConnection();

    logger.d('PostRepository : status internet is $isInternetConnected');

    // checking if data is available or not empty in local storage
    final bool isDataBaseLocalNotEmpty =
        await _postInfiniteProvider.isPostDataAvailable();
    logger.d('isDataBaseLocalNotEmpty $isDataBaseLocalNotEmpty');

    if (isInternetConnected) {
      try {
        final List<Post> response =
            await _postRemoteProvider.fetchPostLimit(start, limit);
        logger.d(
            'Fetch [Post] from the Server and cache it in the local DataBase');

        if (response.isNotEmpty) {
          logger.d('Inserting data to local database');
          await _postInfiniteProvider.fetchAndStoreNewPost(response);
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
}
