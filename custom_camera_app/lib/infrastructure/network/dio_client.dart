import 'package:dio/dio.dart';
import 'package:custom_camera_app/core/constants/app_constants.dart';
import 'package:custom_camera_app/core/logging/app_logger.dart';

/// Dio HTTP client with interceptors
class DioClient {
  late final Dio _dio;

  DioClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(milliseconds: AppConstants.networkTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.networkTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.networkTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(_LoggingInterceptor());

    // Add retry interceptor
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err,
    );
    super.onError(err, handler);
  }
}

/// Retry interceptor with exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio dio;

  _RetryInterceptor(this.dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    const maxAttempts = AppConstants.maxRetryAttempts;
    var delay = AppConstants.retryDelayMs;

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(milliseconds: delay));
      try {
        return await dio.fetch(requestOptions);
      } catch (e) {
        if (i == maxAttempts - 1) rethrow;
        delay *= 2; // Exponential backoff
      }
    }
    throw Exception('Retry failed after $maxAttempts attempts');
  }
}
