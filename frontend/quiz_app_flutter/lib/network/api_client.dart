import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quizzes.dart';

/// Simple singleton API client for the quiz app.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // Base URL for the backend
  static const String _baseUrl =
      'https://quiz-app-assignment-utoe.onrender.com';

  // Default timeout for requests
  final Duration _timeout = const Duration(seconds: 60);

  /// Fetches the available quizzes from GET /quizzes
  /// Returns a [Quizzes] object on success.
  /// Throws [ApiException] on non-200 responses or parse errors.
  Future<Quizzes> fetchQuizzes() async {
    final uri = Uri.parse('$_baseUrl/quizzes');

    http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on TimeoutException catch (e) {
      throw ApiException('Request timed out: ${e.message}');
    } catch (e) {
      throw ApiException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw ApiException('Request failed with status: ${response.statusCode}');
    }

    try {
      final decoded = json.decode(response.body);
      return Quizzes.fromMap(decoded as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to parse response: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
