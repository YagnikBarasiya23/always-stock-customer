import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/utils/api_response_handler.dart';
import '../../core/utils/app_log.dart';
import '../../core/utils/app_utils.dart';
import '../cache/response_cache_service.dart';
import '../constants/url_constants.dart';
import '../local/local_storage_services.dart';

abstract class ApiServices {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([_AuthInterceptor(), _LoggingInterceptor()]);

  static Future<ApiResult> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? cacheKey,
    Duration? cacheTtl,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final result = ApiResponseHandler.process(response);
      if (cacheKey != null) {
        await ResponseCacheService.put(cacheKey, data: result.data, pagination: result.pagination);
      }
      return result;
    } on DioException catch (e) {
      if (cacheKey != null && _isConnectivityFailure(e)) {
        final cached = await ResponseCacheService.get(cacheKey);
        if (cached != null) {
          AppLog.infoLog('Cache', 'Serving cached response for $cacheKey (offline)');
          return ApiResult(data: cached.data, pagination: cached.pagination);
        }
        throw NoInternetException(cause: e);
      }
      throw _handleDioError(e);
    }
  }

  static Future<ApiResult> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? cacheKey,
    Duration? cacheTtl,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      final result = ApiResponseHandler.process(response);
      if (cacheKey != null) {
        await ResponseCacheService.put(cacheKey, data: result.data, pagination: result.pagination);
      }
      return result;
    } on DioException catch (e) {
      if (cacheKey != null && _isConnectivityFailure(e)) {
        final cached = await ResponseCacheService.get(cacheKey);
        if (cached != null) {
          AppLog.infoLog('Cache', 'Serving cached response for $cacheKey (offline)');
          return ApiResult(data: cached.data, pagination: cached.pagination);
        }
        throw NoInternetException(cause: e);
      }
      throw _handleDioError(e);
    }
  }

  static bool _isConnectivityFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return false;
    }
  }

  static ApiException _handleDioError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final body = e.response!.data as Map<String, dynamic>;
      return ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: body['message'] as String? ?? 'Something went wrong',
        errors: body['errors'] as List<dynamic>? ?? [],
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(statusCode: 408, message: 'Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiException(statusCode: 503, message: 'No internet connection.');
      case DioExceptionType.badResponse:
        return ApiException(statusCode: e.response?.statusCode ?? 500, message: 'Server error.');
      case DioExceptionType.cancel:
        return const ApiException(statusCode: 499, message: 'Request cancelled.');
      default:
        return const ApiException(message: 'Something went wrong. Please try again.');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  
  
  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = LocalStorageServices.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path == UrlConstants.refreshToken;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final hasRefreshToken = (LocalStorageServices.getRefreshToken() ?? '').isNotEmpty;

    if (!isUnauthorized || isRefreshCall || alreadyRetried || !hasRefreshToken) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions..extra['retried'] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await ApiServices._dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    _performRefresh(completer);
    return completer.future;
  }

  Future<void> _performRefresh(Completer<String?> completer) async {
    try {
      final refreshToken = LocalStorageServices.getRefreshToken();
      final response = await ApiServices._dio.post(UrlConstants.refreshToken, data: {'refreshToken': refreshToken});
      final result = ApiResponseHandler.process(response);
      final data = result.data as Map<String, dynamic>;
      final accessToken = AppUtils.parseString(data['accessToken']);
      final newRefreshToken = AppUtils.parseString(data['refreshToken']);
      if (accessToken == null || accessToken.isEmpty || newRefreshToken == null || newRefreshToken.isEmpty) {
        throw const ApiException(message: 'Refresh response missing tokens');
      }
      await LocalStorageServices.setTokens(accessToken: accessToken, refreshToken: newRefreshToken);
      completer.complete(accessToken);
    } catch (e) {
      AppLog.errorLog('refreshAccessToken', e);
      await LocalStorageServices.clearTokens();
      await ResponseCacheService.clearAll();
      completer.complete(null);
    } finally {
      _refreshCompleter = null;
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('${options.method} ${options.uri}')
      ..writeln('Headers: ${_pretty(options.headers)}');
    if (options.data != null) {
      buffer.writeln('Body: ${_pretty(options.data)}');
    }
    AppLog.requestLog('API', buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('${response.requestOptions.method} ${response.requestOptions.uri}')
      ..writeln('Status: ${response.statusCode}')
      ..writeln('Body: ${_pretty(response.data)}');
    AppLog.responseLog('API', buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln('Status: ${err.response?.statusCode}')
      ..writeln('Message: ${err.message}');
    if (err.response?.data != null) {
      buffer.writeln('Body: ${_pretty(err.response!.data)}');
    }
    AppLog.errorLog('API', buffer.toString());
    handler.next(err);
  }

  String _pretty(dynamic data) {
    try {
      return _encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
