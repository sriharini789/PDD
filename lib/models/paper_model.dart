class PaperModel {
  final int id;
  final int userId;
  final String title;
  final String authors;
  final String status;
  final String processingStage;
  final String summary; // legacy fallback
  final List<String> topics; // legacy fallback
  final String content;

  // New JSON nested fields
  final Map<String, dynamic> verification;
  final Map<String, dynamic> summaries;
  final Map<String, dynamic> insights;
  final Map<String, dynamic> topicsExt;
  final Map<String, dynamic> citations;
  final Map<String, dynamic> extractedContent;
  final List<dynamic> references;
  final Map<String, dynamic> metrics;

  PaperModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.authors,
    required this.status,
    required this.processingStage,
    required this.summary,
    required this.topics,
    required this.content,
    required this.verification,
    required this.summaries,
    required this.insights,
    required this.topicsExt,
    required this.citations,
    required this.extractedContent,
    required this.references,
    required this.metrics,
  });

  factory PaperModel.fromJson(Map<String, dynamic> json) {
    return PaperModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      title: json['title'] ?? '',
      authors: json['authors'] ?? '',
      status: json['status'] ?? '',
      processingStage: json['processingStage'] ?? json['processing_stage'] ?? '',
      summary: json['summary'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      content: json['content'] ?? '',
      verification: json['verification'] as Map<String, dynamic>? ?? {},
      summaries: json['summaries'] as Map<String, dynamic>? ?? {},
      insights: json['insights'] as Map<String, dynamic>? ?? {},
      topicsExt: json['topicsExt'] as Map<String, dynamic>? ?? {},
      citations: json['citations'] as Map<String, dynamic>? ?? {},
      extractedContent: json['extractedContent'] as Map<String, dynamic>? ?? {},
      references: json['references'] as List<dynamic>? ?? [],
      metrics: json['metrics'] as Map<String, dynamic>? ?? {},
    );
  }
}