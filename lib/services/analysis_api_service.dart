import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/models/analysis_request_model.dart';
import 'package:smart_expens/models/analysis_response_model.dart';

/// Communicates with the external spending analysis API.
///
/// Endpoint: POST https://ahmed-m-final-project.hf.space/analyze
class AnalysisApiService {
  static const String _baseUrl = 'https://ahmed-m-final-project.hf.space';

  late final Dio _dio;

  AnalysisApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Sends spending data to the analysis API and returns parsed insights.
  Future<AnalysisResponseModel> analyze(AnalysisRequestModel request) async {
    try {
      debugPrint(' AnalysisApiService.analyze → ${request.toJson()}');

      final response = await _dio.post('/analyze', data: request.toJson());

      debugPrint(' AnalysisApiService.analyze → status=${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{'result': response.data.toString()};

        return AnalysisResponseModel.fromJson(data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint(' AnalysisApiService.analyze DioException: ${e.message}');

      String message;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Cannot reach the analysis server. Check your connection.';
      } else if (e.response?.statusCode == 422) {
        message = 'Invalid data sent to analysis. Please check your expenses.';
      } else {
        message = 'Analysis failed: ${e.message ?? 'Unknown error'}';
      }

      throw AnalysisApiException(message: message, cause: e);
    } catch (e) {
      debugPrint(' AnalysisApiService.analyze unexpected: $e');
      throw AnalysisApiException(
        message: 'An unexpected error occurred during analysis.',
        cause: e,
      );
    }
  }
}

/// Exception specific to analysis API failures.
class AnalysisApiException implements Exception {
  final String message;
  final Object? cause;

  const AnalysisApiException({required this.message, this.cause});

  @override
  String toString() => 'AnalysisApiException: $message';
}
