import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import flutter_local_notifications package
import 'api_call.dart';
import 'ils_screen.dart';
import 'package:videosdk/videosdk.dart';

class JoinScreen extends StatelessWidget {
  final _meetingIdController = TextEditingController();

  JoinScreen({Key? key});

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the settings for the push notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Show a push notification
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'videosdk_channel_id', // ID for the notification channel
      'VideoSDK Notifications', // Name for the notification channel
      'Push notifications for VideoSDK', // Description for the notification channel
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Meeting Created', // Notification title
      'Your meeting has been created successfully.', // Notification body
      platformChannelSpecifics,
    );
  }

  // Creates new Meeting Id and joins it in CONFERENCE mode.
  void onCreateButtonPressed(BuildContext context) async {
    // Call API to create meeting and navigate to ILSScreen with meetingId, token, and mode
    await createMeeting().then((meetingId) {
      if (!context.mounted) return;
      // Show push notification when meeting is created
      _showNotification();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ILSScreen(
            meetingId: meetingId,
            token: token,
            mode: Mode.CONFERENCE,
          ),
        ),
      );
    });
  }

  // Join the provided meeting with given Mode and meetingId
  void onJoinButtonPressed(BuildContext context, Mode mode) {
    // check meeting id is not null or invalid
    // if meeting id is valid then navigate to ILSScreen with meetingId, token, and mode
    String meetingId = _meetingIdController.text;
    var re = RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
    if (meetingId.isNotEmpty && re.hasMatch(meetingId)) {
      _meetingIdController.clear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ILSScreen(
            meetingId: meetingId,
            token: token,
            mode: mode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid meeting id"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize push notifications when the widget is built
    _initializeNotifications();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('VideoSDK ILS QuickStart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Creating a new meeting
            ElevatedButton(
              onPressed: () => onCreateButtonPressed(context),
              child: const Text('Create Meeting'),
            ),
            const SizedBox(height: 40),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter Meeting Id',
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white),
              ),
              controller: _meetingIdController,
            ),
            // Joining the meeting as host
            ElevatedButton(
              onPressed: () => onJoinButtonPressed(context, Mode.CONFERENCE),
              child: const Text('Join Meeting as Host'),
            ),
            // Joining the meeting as viewer
            ElevatedButton(
              onPressed: () => onJoinButtonPressed(context, Mode.VIEWER),
              child: const Text('Join Meeting as Viewer'),
            ),
          ],
        ),
      ),
    );
  }
}

