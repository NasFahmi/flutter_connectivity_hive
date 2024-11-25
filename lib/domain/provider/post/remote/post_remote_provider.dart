import 'package:connectivity_hive_bloc/config/api/EndPoints.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/services/api_client.dart';
import 'package:connectivity_hive_bloc/domain/services/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/domain/services/utils/logger.dart';

class PostRemoteProvider {
  ApiClient _apiClient = di<ApiClient>();
  Future<Post> fetchAllPosts() async {
    try {
      final response = await _apiClient.get(Endpoints.post);
      if (response.statusCode == 200) {
        // If the server returns an OK response,
        // then parse the JSON.
        final posts = Post.fromJson(response.data);
        logger.d('Succesfull fecthing posts');
        return posts;
      }

      // If the server did not return an OK response,
      // then throw an exception.
      logger.d('failed fecthing posts');
      throw Exception('Failed to load posts');
    } catch (e) {
      logger.d('failed fecthing posts ${e}');
      throw Exception('Failed to load posts ${e}');
    }
  }
}
