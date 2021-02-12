import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_reminder/database/database_helper.dart';
import 'package:smart_reminder/database/model/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class AddReminderPage extends StatefulWidget {
  Reminder reminder;
  bool isEdit;
  Function() onSave;

  AddReminderPage(bool isEdit, Reminder reminder, Function() onSave) {
    this.isEdit = isEdit;
    this.reminder = reminder;
    this.onSave = onSave;
  }

  @override
  State<StatefulWidget> createState() => new _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage>{
  DateTime selectedDate;
  TimeOfDay selectedTime;
  DateTime finalDate;
  String saveText = "";
  bool prevInit = false;
  bool timeOrDateEdit = false;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm");

  @override
  void initState() {
    super.initState();

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid,
        initializationSettingsIOS
    );

    flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    await Future.delayed(Duration(milliseconds: 100));

    DateTime initDate = selectedDate;

    if(selectedDate == null){
      initDate = DateTime.now();
    }

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101)
    );

    setState(() {
      selectedDate = picked;
      timeOrDateEdit = true;
    });
  }

  Future<Null> _selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    await Future.delayed(Duration(milliseconds: 100));

    TimeOfDay initTime = selectedTime;

    if(selectedTime == null){
      initTime = TimeOfDay.now();
    }

    final TimeOfDay pickedTime = await showTimePicker(
        context: context,
        initialTime: initTime,
    );


    setState(() {
      selectedTime = pickedTime;
      timeOrDateEdit = true;
    });
  }

  DateTime constructDate(DateTime date, TimeOfDay time){
    if (date == null){
      return null;
    }

    if (date != null && time == null){
      return new DateTime(date.year, date.month, date.day);
    }

    return new DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  int finalDateInt (DateTime date){
    if (date != null){
      return date.millisecondsSinceEpoch;
    }
    return null;
  }

  Future onSelectNotification(String payload) {

  }

  Future onDidReceiveLocalNotification(int hi, String one, String two,
      String three) {

  }

  Future<void> scheduledNotification(String contents, DateTime date, int notificationId) async {
    var scheduledNotificationDateTime = date;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ReminderChannel',
        'Reminders',
        'Reminder Notifications',
        icon: 'secondary_icon',
        color: const Color.fromARGB(255, 255, 0, 164),
        ledColor: const Color.fromARGB(255, 255, 0, 164),
        ledOnMs: 1000,
        ledOffMs: 1000
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics
    );

    await flutterLocalNotificationsPlugin.schedule(
        notificationId,
        contents,
        contents,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: 'item x'
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEdit && widget.reminder == null && timeOrDateEdit == false) {
      widget.reminder = new Reminder("", null);
      selectedDate = null;
      selectedTime = null;
    } else if (widget.reminder.id != null) {
      if (saveText.isEmpty) {
        saveText = widget.reminder.text;
      }
      if (widget.reminder.date != null && !timeOrDateEdit) {
        selectedDate = new DateTime.fromMillisecondsSinceEpoch(widget.reminder.date);
        selectedTime = TimeOfDay.fromDateTime(selectedDate);
      }
    }

    String displayDate = "None";
    String displayTime = "None";

    if(selectedDate != null){
      displayDate = dateFormat.format(selectedDate);
    }

    if(selectedTime != null){
      final now = new DateTime.now();
      final selectedDateTime = new DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      displayTime = timeFormat.format(selectedDateTime);
    }

    return new Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(color: Colors.grey[700]),
        title: new Text(widget.isEdit ? 'Edit' : 'Add new Reminder',
            style: TextStyle(color: Colors.grey[700])),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(32.0),
              child: getTextField("Enter Text:", saveText),
            ),

            Padding(
              padding: EdgeInsets.only(top:32.0, right:32.0, bottom:32.0, left:52.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Select Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      MaterialButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Row( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            //day number month
                            Text(displayDate,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            Icon(Icons.keyboard_arrow_right, color: Colors.pink),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Select Time:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      MaterialButton(
                        onPressed: () {
                          _selectTime(context);
                        },
                        child: Row( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Text(displayTime,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            Icon(Icons.keyboard_arrow_right, color: Colors.pink),
                          ],
                        ),
                        //color: Colors.pink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

      ),



      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          _showNoDateDialog(context),
        },
        tooltip: 'Done',
        icon: Icon(Icons.done),
        label: const Text('Done'),
      ),
    );
  }

  void _showNoDateDialog(BuildContext context) {
    if ((selectedDate == null && selectedTime != null) ||
        (selectedDate != null && selectedTime == null)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Oops!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Date and time must both be selected for a notification to occur',
                    style: TextStyle(fontStyle: FontStyle.italic),),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('GO BACK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }else if(saveText == null || saveText == "") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Oops!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You have not chosen any text for the reminder!',
                    style: TextStyle(fontStyle: FontStyle.italic),),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('GO BACK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }else{
      finalDate = constructDate(selectedDate, selectedTime);
      final id = widget.reminder.id;
      final previousNotificationId = widget.reminder.notificationId();
      widget.reminder = new Reminder(saveText, finalDateInt(finalDate));
      widget.reminder.setReminderId(id);
      addRecord(widget.isEdit, widget.reminder, previousNotificationId);

      Navigator.pop(context);
    }
  }

  Widget getTextField(String hint, String text) {
    var textBtn = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new TextField(
        controller: TextEditingController()..text = text,
        decoration: new InputDecoration(hintText: hint),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (text) => saveText = text,
      ),
    );
    return textBtn;
  }

  Future addRecord(bool isEdit, Reminder reminder, int previousNotificationId) async {
    var db = new DatabaseHelper();
    if (isEdit){
      reminder.setReminderId(widget.reminder.id);
      await db.update(reminder);
    } else {
      final id = await db.saveReminder(reminder);
      reminder.setReminderId(id);
    }
    if (previousNotificationId != null) {
      flutterLocalNotificationsPlugin.cancel(previousNotificationId);
    }
    if (reminder.notificationId() != null) {
      scheduledNotification(saveText, finalDate, reminder.notificationId());
    }
    widget.onSave();
  }
}
