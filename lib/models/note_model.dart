class NoteModel {
  final int id;
  final int paperId;
  final String content;
  final String? highlightedText;
  final int? pageNumber;

  NoteModel({
    required this.id,
    required this.paperId,
    required this.content,
    this.highlightedText,
    this.pageNumber,
  });
}