import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timer/core/utils/notifications.dart';

@GenerateNiceMocks([MockSpec<FlutterLocalNotificationsPlugin>()])
import 'notifications_test.mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NotificationHelper notificationHelper;

  setUp(() {
    flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    notificationHelper = NotificationHelperImpl(
        localNotificationsPlugin: flutterLocalNotificationsPlugin);
  });

  group('NotificationHelper', () {
    test(
        'should call `flutterLocalNotificationsPlugin.intialize` when `intialize` method get called',
        () {
      notificationHelper.initialize();

      verify(flutterLocalNotificationsPlugin.initialize(any,
              onDidReceiveNotificationResponse:
                  anyNamed('onDidReceiveNotificationResponse')))
          .called(1);
    });

    test(
        'should call `flutterLocalNotificationsPlugin.show` when `show` method get called',
        () {
      notificationHelper.show('title', 'body');

      verify(flutterLocalNotificationsPlugin.show(
              any, 'title', 'body', any, payload: anyNamed('payload')))
          .called(1);
    });

    test(
        'should call `flutterLocalNotificationsPlugin.show` when `showTimerCounter` method get called',
        () {
      notificationHelper.showTimerCounter('title', 'body');

      verify(flutterLocalNotificationsPlugin.show(
              any, 'title', 'body', any, payload: anyNamed('payload')))
          .called(1);
    });

    test('shoudl call `flutterLocalNotificationsPlugin.cancel` when `dismiss` method get called', () {
      notificationHelper.dismiss(1);

      verify(flutterLocalNotificationsPlugin.cancel(1)).called(1);
    });
  });
}
