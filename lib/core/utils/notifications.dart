// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro_timer/core/constants.dart';

class NotificationChannel {
  final String id;
  final String name;
  final String description;
  final bool ongoing;
  final bool channelShowBadge;
  final bool enableVibration;
  final bool playSound;
  final Importance importance;
  final List<AndroidNotificationAction>? actions;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.defaultImportance,
    this.ongoing = false,
    this.channelShowBadge = true,
    this.enableVibration = true,
    this.playSound = true,
    this.actions,
  });

  AndroidNotificationDetails get androidNotificationDetails =>
      AndroidNotificationDetails(
        id,
        name,
        channelDescription: description,
        ongoing: ongoing,
        actions: actions,
        importance: importance,
        priority: Priority.high,
        channelShowBadge: channelShowBadge,
        enableVibration: enableVibration,
        playSound: playSound, 
      );
}

abstract class NotificationHelper {
  // void initialize(Future<void> Function(ReceivedAction) onActionReceivedMethod);
  void initialize(
      {void Function(NotificationResponse)? onDidReceiveNotificationResponse});
  void show(String title, String body, {String? payload});
  void showTimerCounter(
    String title,
    String body,
  );
  void dismiss(int id);
}

class NotificationHelperImpl extends NotificationHelper {
  int id = 5;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  NotificationHelperImpl(
      {FlutterLocalNotificationsPlugin? localNotificationsPlugin})
      : _localNotificationsPlugin =
            localNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  void initialize(
      {void Function(NotificationResponse)?
          onDidReceiveNotificationResponse}) async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveNotificationResponse,
    );
  }

  @override
  void show(String title, String body, {String? payload}) {
    final androidNotificationDetails = const NotificationChannel(
      id: 'general_notification',
      name: 'General Notification',
      description:
          'This is just some general notification, you can turn this off if you don\'t care about any notification other than the timer',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'id_1',
          'Play',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'id_2',
          'Pause',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'id_3',
          'Skip',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
      importance: Importance.max,
    ).androidNotificationDetails;

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    _localNotificationsPlugin.show(
      id++,
      title,
      body,
      notificationDetails,
    );
  }

  @override
  void showTimerCounter(
    String title,
    String body,
  ) {
    final androidNotificationDetails = const NotificationChannel(
      id: 'timer_counter',
      name: 'Timer Counter',
      description: 'This is the timer counter notification',
      ongoing: true,
      channelShowBadge: false,
      enableVibration: false,
      playSound: false,
    ).androidNotificationDetails;

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    _localNotificationsPlugin.show(
      timerCounterNotificationId,
      title,
      body,
      notificationDetails,
    );
  }

  @override
  void dismiss(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }
}
