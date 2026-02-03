import 'package:dio/dio.dart';

// Базовый класс для всех ошибок приложения
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

// Конкретные ошибки
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = "Unauthorized"])
      : super(code: "401");
}

class NotFoundException extends AppException {
  NotFoundException([super.message = "Resource not found"])
      : super(code: "404");
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: "validation_error");
}

// Фабрика для преобразования DioException → AppException
AppException handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException("Connection timeout. Please check your internet.");
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      final msg = error.response?.data?['detail'] ?? error.message ?? "Server error";
      if (status == 401 || status == 403) {
        return UnauthorizedException(msg);
      }
      if (status == 404) {
        return NotFoundException(msg);
      }
      if (status == 422 || status == 400) {
        return ValidationException(msg);
      }
      return ServerException(msg, code: status?.toString());
    case DioExceptionType.cancel:
      return NetworkException("Request cancelled");
    case DioExceptionType.unknown:
    default:
      return NetworkException("Something went wrong. Please try again.");
  }
}