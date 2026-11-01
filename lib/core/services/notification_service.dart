import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  Future<void> showBudgetAlert(String budgetName) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'budget_alerts',
        'Budget alerts',
        channelDescription: 'Alerts when spending approaches a budget limit.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _notifications.show(
      budgetName.hashCode,
      'Budget alert',
      '$budgetName is close to its limit.',
      details,
    );
  }
}
