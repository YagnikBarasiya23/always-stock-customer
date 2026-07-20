import 'package:dio/dio.dart';

import 'app_utils.dart';

class Pagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const Pagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    final page = AppUtils.parseInt(json['page']) ?? 1;
    final limit = AppUtils.parseInt(json['limit']) ?? 20;
    final totalItems = AppUtils.parseInt(json['total']) ?? 0;

    // The backend meta only carries {page, limit, total} — derive the rest.
    final derivedTotalPages = limit > 0 ? (totalItems / limit).ceil() : 0;
    final totalPages = AppUtils.parseInt(json['totalPages']) ?? derivedTotalPages;

    return Pagination(
      page: page,
      limit: limit,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: AppUtils.parseBool(json['hasNextPage']) ?? page < totalPages,
      hasPrevPage: page > 1,
    );
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final String message;
  final bool success;
  final List<dynamic> errors;
  final Pagination? pagination;

  const ApiResponse({
    required this.statusCode,
    this.data,
    required this.message,
    required this.success,
    this.errors = const [],
    this.pagination,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final paginationData = json['meta'];
    return ApiResponse(
      statusCode: AppUtils.parseInt(json['statusCode']) ?? 500,
      data: json['data'],
      message: AppUtils.parseString(json['message']) ?? '',
      success: AppUtils.parseBool(json['success']) ?? false,
      errors: json['errors'] as List<dynamic>? ?? [],
      pagination: paginationData is Map<String, dynamic> ? Pagination.fromJson(paginationData) : null,
    );
  }
}

class ApiResult {
  final dynamic data;
  final Pagination? pagination;

  const ApiResult({this.data, this.pagination});
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<dynamic> errors;

  const ApiException({this.statusCode = 500, this.message = 'Something went wrong', this.errors = const []});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NoInternetException extends ApiException {
  final DioException? cause;

  const NoInternetException({this.cause}) : super(statusCode: 503, message: 'No internet connection.');
}

/// User-facing message for any error thrown by the data layer.
String apiErrorMessage(Object error) =>
    error is ApiException ? error.message : 'Something went wrong. Please try again.';

abstract class ApiResponseHandler {
  static ApiResult process(Response response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      return ApiResult(data: body);
    }

    final apiResponse = ApiResponse.fromJson(body);

    if (!apiResponse.success) {
      throw ApiException(statusCode: apiResponse.statusCode, message: apiResponse.message, errors: apiResponse.errors);
    }

    return ApiResult(data: apiResponse.data, pagination: apiResponse.pagination);
  }
}
