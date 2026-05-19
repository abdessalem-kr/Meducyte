import 'package:meducyte_app/export.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors; //For validation errors

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => message;

  //Check if this is a validation error with multiple fields
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  //Get all validation error messages as a list
  List<String> get validationMessages {
    if (!hasValidationErrors) return [];

    final messages = <String>[];
    errors!.forEach((field, value) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else {
        messages.add(value.toString());
      }
    });
    return messages;
  }

  //Factory constructor to parse Laravel error responses
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout.Please check your internet connection.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection.Please try again.',
          statusCode: null,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled.', statusCode: null);

      default:
        return ApiException(
          message: 'Something went wrong.Please try again.',
          statusCode: null,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    if (response == null) {
      return ApiException(
        message: 'No response from server.',
        statusCode: null,
      );
    }

    final data = response.data;
    final statusCode = response.statusCode;

    //Ensure data is a Map
    if (data is! Map<String, dynamic>) {
      return ApiException(
        message: _getStatusMessage(statusCode),
        statusCode: statusCode,
      );
    }

    //Handle Laravel validation errors(422)
    if (statusCode == 422) {
      final errors = data['errors'] as Map<String, dynamic>?;

      if (errors != null && errors.isNotEmpty) {
        //Get the first error message from the first field
        final firstFieldErrors = errors.values.first;
        String errorMessage;

        if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
          errorMessage = firstFieldErrors.first.toString();
        } else {
          errorMessage = firstFieldErrors.toString();
        }

        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          errors: errors,
        );
      }

      //Fallback if no errors array
      return ApiException(
        message: data['message'] as String? ?? 'Validation failed.',
        statusCode: statusCode,
      );
    }

    //Handle standard Laravel error responses with'message'field
    final message = data['message'] as String?;
    final error = data['error'] as String?;

    if (message != null || error != null) {
      return ApiException(
        message: message ?? error!,
        statusCode: statusCode,
        errors: data['errors'] as Map<String, dynamic>?,
      );
    }

    //Fallback for unexpected response format
    return ApiException(
      message: _getStatusMessage(statusCode),
      statusCode: statusCode,
    );
  }

  static String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.Please check your input.';
      case 401:
        return 'Unauthorized.Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests.Please try again later.';
      case 500:
        return 'Server error.Please try again later.';
      case 503:
        return 'Service unavailable.Please try again later.';
      default:
        return 'An error occurred.Please try again.';
    }
  }
}

//Keep your EmailNotVerifiedException
class EmailNotVerifiedException implements Exception {
  final String email;
  EmailNotVerifiedException(this.email);

  @override
  String toString() =>
      'Email not verified.Please check your email for verification code.';
}
