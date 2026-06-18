class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
  });
}