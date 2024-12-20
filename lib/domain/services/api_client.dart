import 'dart:async';
import 'package:connectivity_hive_bloc/domain/services/token_service.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  final T data;
  final String message;
  final int statusCode;
  final Map<String, String> headers;

  ApiResponse({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.headers,
  });
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class ApiClient {
  final Duration timeout;
  final TokenService tokenService;
  late Dio dio;

  ApiClient(
    this.tokenService, {
    this.timeout = const Duration(seconds: 30),
  }) {
    dio = Dio(BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    // Menambahkan interceptor untuk menangani JWT
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // if (e.response?.statusCode == 401) {
        //   // !cehcking accestoken is exp
        //   logger.d('acces token exp');
        //   await _handleUnauthorizedError();
        // }
        logger.d('acces Token Exp');
        return handler.next(e);
      },
    ));
  }
  // Future<void> _handleUnauthorizedError() async {
  //   try {
  //     // Coba refresh token
  //     await generateRefreshToken();
  //   } catch (e) {
  //     // Jika refresh token gagal, paksa logout
  //     await _forceLogout();
  //   }
  // }

  // Future<void> generateRefreshToken() async {
  //   final refreshToken = await tokenService.getRefreshToken();
  //   try {
  //     final response = await di<AuthenticationProvider>().refreshToken(refreshToken!);

  //     if (response.statusCode == 401) {
  //       // Invalid refresh token, trigger logout
  //       logger.d('failed create accesToken and refreshToken and accesToken token exp,');
  //       await _forceLogout();
  //     } else {
  //       logger.d('succesfull create accesToken');
  //       // Proses refresh token normal
  //       await tokenService.deleteAccessToken();
  //       final accesToken = response.data['data']['access_token'] as String;
  //       await tokenService.saveAccessToken(accesToken);
  //     }
  //   } catch (e) {
  //     await _forceLogout();
  //   }
  // }

  // Future<void> _forceLogout() async {
  //   // Hapus semua token dan data pengguna
  //   await tokenService.deleteAccessToken();
  //   await tokenService.deleteRefreshToken();
  //   await di<SharedPreferencesService>().clearAllData();
  //   logger.d('set authentication to authLogoutRequest');
  //   // Trigger event logout di AuthBloc
  //   di<AuthBloc>().add(AuthLogoutRequested());
  // }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      logger.d(
          "fetching api get, status code ${response.statusCode}");
      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      logger.d(
          "fetching api post, status code ${response.statusCode} data ${response.data}");
      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      logger.d(
          "fetching api put, status code ${response.statusCode} data ${response.data}");
      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      logger.d(
          "fetching api delete, status code ${response.statusCode} data ${response.data}");
      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(Response response) {
    final body = response.data;

    // Fungsi pembantu untuk mengonversi headers
    Map<String, String> _convertHeaders(Headers headers) {
      return headers.map.map((key, value) =>
          MapEntry(key, (value is List) ? value.join(',') : value.toString()));
    }

    // Fungsi pembantu untuk mengekstrak pesan dengan aman
    String _safeGetMessage(dynamic body) {
      if (body is Map) {
        return body['message'] ?? 'No message available';
      }
      return 'No message available';
    }

    // Fungsi pembantu untuk mengekstrak data dengan aman
    dynamic _safeGetData(dynamic body) {
      if (body is Map) {
        return body['data'] ?? body;
      }
      return body;
    }

    // Pemeriksaan null safety untuk status code
    if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
      return ApiResponse<T>(
        headers: _convertHeaders(response.headers),
        statusCode: response.statusCode!,
        message: _safeGetMessage(body),
        data: _safeGetData(body),
      );
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
      case 401:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
      case 403:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
      case 404:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
      case 500:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
      default:
        throw ApiException(
          message: _safeGetMessage(body),
          statusCode: response.statusCode,
          data: body,
        );
    }
  }
}
