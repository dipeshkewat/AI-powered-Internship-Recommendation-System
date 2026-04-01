import 'package:dio/dio.dart';

/// Maps exceptions to clean, user-facing messages.
/// Use throughout the app instead of raw e.toString().
class ErrorHandler {
  ErrorHandler._();

  static String message(Object error) {
    if (error is DioException) {
      return _dioMessage(error);
    }
    if (error is FormatException) {
      return 'Invalid data received from server. Please try again.';
    }
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('NetworkException')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _dioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Try again later.';
      case DioExceptionType.connectionError:
        return 'Could not connect to server. Check your internet connection.';
      case DioExceptionType.badResponse:
        return _statusMessage(e.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error. Please try again.';
    }
  }

  static String _statusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to do this.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This account already exists. Try logging in.';
      case 422:
        return 'Invalid data submitted. Please review your input.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Unexpected error (code: $statusCode). Please try again.';
    }
  }

  /// Returns true if the error is network-related (no connectivity).
  static bool isNetworkError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout;
    }
    return error.toString().contains('SocketException');
  }

  /// Returns true if auth token is invalid/expired.
  static bool isAuthError(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }
}
