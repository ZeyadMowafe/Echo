import 'package:dio/dio.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showError(BuildContext context, Failure failure) {
    final message = _mapFailureToMessage(failure);
    _showSnackBar(context, message);
  }

  static void showErrorFromException(BuildContext context, Object error) {
    final message = _mapExceptionToMessage(error);
    _showSnackBar(context, message);
  }

  static void showDioError(BuildContext context, DioException error) {
    final message = _mapDioExceptionToMessage(error);
    _showSnackBar(context, message);
  }

  static void logError(String message, [Object? error, StackTrace? stack]) {
    debugPrint('═══════════ ERROR ═══════════');
    debugPrint('$message${error != null ? ': $error' : ''}');
    if (stack != null) debugPrintStack(stackTrace: stack);
    debugPrint('═════════════════════════════');
  }

  static String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection';
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty ? failure.message : 'Server error occurred';
    }
    if (failure is CacheFailure) {
      return failure.message.isNotEmpty ? failure.message : 'Storage error occurred';
    }
    return 'Something went wrong';
  }

  static String _mapExceptionToMessage(Object error) {
    if (error is ServerFailure) return _mapFailureToMessage(error);
    if (error is NetworkFailure) return _mapFailureToMessage(error);
    if (error is Failure) return _mapFailureToMessage(error);
    return 'Unexpected error occurred';
  }

  static String _mapDioExceptionToMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Session expired. Please login again';
        if (code == 404) return 'Resource not found';
        if (code == 500) return 'Server error. Try again later';
        return error.response?.statusMessage ?? 'Request failed ($code)';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.badCertificate:
        return 'Security error occurred';
      case DioExceptionType.unknown:
        return 'Something went wrong';
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
