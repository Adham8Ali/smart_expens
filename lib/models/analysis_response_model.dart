/// Wraps the analysis API response.
///
/// The API's OpenAPI spec declares an empty response schema, so this model
/// stores the raw JSON map and provides typed convenience accessors.
class AnalysisResponseModel {
  /// Raw response from the API.
  final Map<String, dynamic> rawData;

  /// Timestamp of when this analysis was fetched.
  final DateTime fetchedAt;

  const AnalysisResponseModel({
    required this.rawData,
    required this.fetchedAt,
  });

  factory AnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResponseModel(
      rawData: json,
      fetchedAt: DateTime.now(),
    );
  }

  /// Returns all top-level keys as displayable insight entries.
  List<MapEntry<String, dynamic>> get insights => rawData.entries.toList();

  /// Checks if the response contains any data.
  bool get hasData => rawData.isNotEmpty;

  /// Safe accessor for a specific field.
  dynamic operator [](String key) => rawData[key];

  @override
  String toString() => 'AnalysisResponseModel(keys: ${rawData.keys.toList()})';
}
