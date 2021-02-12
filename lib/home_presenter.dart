import 'package:smart_reminder/database/database_helper.dart';
import 'package:smart_reminder/database/model/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'database/model/reminder.dart';

abstract class HomeContract {
  void screenUpdate();
}

class HomePresenter {
  HomeContract _view;
  var db = new DatabaseHelper();
  HomePresenter(this._view);
  List<Reminder> doneReminders = List();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  delete(Reminder reminder) {
    var db = new DatabaseHelper();
    doneReminders.removeWhere((element) => element.id == reminder.id);
    db.deleteReminders(reminder);
    updateScreen();

    final id = reminder.notificationId();
    if (id != null) {
      flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  markAsDone(Reminder reminder) {
    doneReminders.add(reminder);
    updateScreen();
  }

  Future<List<Reminder>> getReminder() {
    return db.getReminder().then((value) => value.map((e) =>
        updateDoneField(e)).toList()
    );
  }

  Reminder updateDoneField(Reminder reminder) {
    reminder.done = doneReminders.where((element) => element.id == reminder.id).isNotEmpty;
    print(reminder.notificationId());
    return reminder;
  }

  updateScreen() {
    _view.screenUpdate();
  }
}
