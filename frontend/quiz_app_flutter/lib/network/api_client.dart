import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quizzes.dart';
import '../models/questions.dart';
import '../models/quiz_response.dart';

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

  /// Fetches questions for a specific quiz id: GET /quizzes/{id}/questions
  Future<Questions> fetchQuizQuestions(int id) async {
    final uri = Uri.parse('$_baseUrl/quizzes/$id/questions');

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
      return Questions.fromMap(decoded as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to parse response: $e');
    }
  }

  /// Submits a quiz response. POST /responses with the QuizResponse JSON.
  /// Returns true on success (2xx).
  Future<bool> submitQuizResponse(QuizResponse response) async {
    final uri = Uri.parse('$_baseUrl/responses');

    http.Response httpResponse;
    try {
      httpResponse = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: quizResponseToMap(response),
          )
          .timeout(_timeout);
    } on TimeoutException catch (e) {
      throw ApiException('Request timed out: ${e.message}');
    } catch (e) {
      throw ApiException('Network error: $e');
    }

    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
      return true;
    }

    throw ApiException('Submit failed with status: ${httpResponse.statusCode}');
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
