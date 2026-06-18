import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return [
      NotificationModel(id: 1, title: 'Welcome', message: 'Welcome to Research AI', isRead: false),
    ];
  }
}

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(() => NotificationNotifier());