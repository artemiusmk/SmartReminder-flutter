import 'package:flutter/material.dart';
import 'package:smart_reminder/ui/add_reminder/add_reminder_page.dart';
import 'package:smart_reminder/model/reminder.dart';
import 'package:smart_reminder/ui/home/home_presenter.dart';
import 'package:smart_reminder/ui/home/list_widget.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements HomeContract {
  HomePresenter homePresenter;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    homePresenter = new HomePresenter(this);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS;

    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Smart Reminder',
            style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
      ),
      body: new FutureBuilder<List<Reminder>>(
        future: homePresenter.getReminder(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          var data = snapshot.data;
          return snapshot.hasData
              ? new ReminderList(data, homePresenter)
              : new Center(child: new CircularProgressIndicator());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReminderPage(false, null, homePresenter.updateScreen),
          ),
        ),
        tooltip: 'New Reminder',
        icon: Icon(Icons.add),
        label: const Text('Add Reminder'),
        elevation: 2,
      ),
    );
  }

  @override
  void screenUpdate() {
    setState(() {});
  }
}
