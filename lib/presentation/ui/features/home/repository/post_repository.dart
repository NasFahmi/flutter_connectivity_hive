import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_provider.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/remote/post_remote_provider.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/domain/services/utils/logger.dart';

class PostRepository {
  // remote provider
  final PostRemoteProvider _postRemoteProvider;
  // local provider
  final PostLocalProvider _postLocalProvider;
  PostRepository(this._postRemoteProvider, this._postLocalProvider);

  Future<Post> getPost() async {
    // Connection checker
    final bool isInternetConnected =
        await di<InternetConnectionServices>().checkInternetConnection();

    /// is DataBase local Empty or Not
    final bool isDataBaseEmpty = await _postLocalProvider.isPostDataAvailable();

    // jika ada koneksi/ connection true
    if (isInternetConnected) {
      try {
        // Fetch From Server and cache it
        final Post response = await _postRemoteProvider.fetchAllPosts();
        logger.d(
            'Fetch [Post] from the Server and cache it in the local DataBase');

        /// Success
        if (response != null) {
          // insert to db local
          logger.d('inserting data to local database');
          _postLocalProvider.insertPost(data: response);

          /// send the cached data to server
          final Post? cachedPost = await _postLocalProvider.getPosts();
          logger.d('return data from local database');
          /// Send it to state management class as success response
          return cachedPost!;
        }

        /// Unknown Error
        else {
          /// Read From DB
          if (!isDataBaseEmpty) {
            logger.d('Load [Post] from Local DataBase');

            final Post? localPostData = await _postLocalProvider.getPosts();
            return localPostData!;
          }

          /// Failed
          return throw Exception("Unknown Error Happened!");
        }
      } catch (e) {
        if (!isDataBaseEmpty) {
          logger.d('Load [Post] from Local DataBase');
          final Post? localPostData = await _postLocalProvider.getPosts();
          return localPostData!;
        }

        /// Error
        else {
          return throw Exception("Unknown Error Happened!");
        }
      }
    }

    /// Use data from the database
    // !jika tidak ada internet
    else {
      // ! jika database tidak kosong
      if (!isDataBaseEmpty) {
        logger.d('Load [Post] from Local DataBase');
        final Post? localPostData = await _postLocalProvider.getPosts();
        return localPostData!;
      }

      // ! jika database kosong
      else {
        return throw Exception('No Network Connection!');
      }
    }
  }
}
