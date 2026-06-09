import 'package:flutter/foundation.dart';
import 'package:smart_expens/models/analysis_request_model.dart';
import 'package:smart_expens/models/analysis_response_model.dart';
import 'package:smart_expens/models/expense_model.dart';
import 'package:smart_expens/services/analysis_api_service.dart';

/// Manages the spending analysis state from the external API.
///
/// Caches the latest analysis result in memory so navigating away
/// and back to the reports screen doesn't re-fetch unless requested.
class AnalysisProvider with ChangeNotifier {
  final AnalysisApiService _service = AnalysisApiService();

  // ─── State ──────────────────────────────────────────────────────────────────

  AnalysisResponseModel? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────

  AnalysisResponseModel? get analysisResult => _analysisResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasResult => _analysisResult != null;

  // ─── Actions ────────────────────────────────────────────────────────────────

  /// Fetches a spending analysis from the external API.
  ///
  /// Transforms the user's expenses into the API format,
  /// sends the request, and caches the result.
  Future<void> fetchAnalysis({
    required List<ExpenseModel> expenses,
    required double salary,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final request = AnalysisRequestModel.fromExpenses(
        expenses: expenses,
        salary: salary,
      );

      debugPrint(' AnalysisProvider.fetchAnalysis → ${request.toJson()}');

      _analysisResult = await _service.analyze(request);

      debugPrint(
        ' AnalysisProvider: received analysis with '
        '${_analysisResult!.rawData.length} fields',
      );
    } on AnalysisApiException catch (e) {
      _errorMessage = e.message;
      debugPrint(' AnalysisProvider: ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      debugPrint(' AnalysisProvider unexpected: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the cached analysis result.
  void clearResult() {
    _analysisResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears only the error state.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
