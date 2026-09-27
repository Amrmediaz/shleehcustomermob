class FlatsResponse {
  final List<dynamic> results;
  final int currentPage;
  final int pageCount;
  final int rowCount;
  final int pageSize;

  FlatsResponse({
    required this.results,
    required this.currentPage,
    required this.pageCount,
    required this.rowCount,
    required this.pageSize,
  });

  factory FlatsResponse.fromJson(Map<String, dynamic> json) {
    return FlatsResponse(
      results: json['results'] as List? ?? [],
      currentPage: json['currentPage'] as int? ?? 1,
      pageCount: json['pageCount'] as int? ?? 1,
      rowCount: json['rowCount'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}