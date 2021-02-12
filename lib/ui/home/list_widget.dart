import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_reminder/model/reminder.dart';
import 'package:smart_reminder/ui/home/home_presenter.dart';
import 'package:smart_reminder/ui/add_reminder/add_reminder_page.dart';
import 'package:intl/intl.dart';

class ReminderList extends StatelessWidget {
  final List<Reminder> reminders;
  final HomePresenter homePresenter;
  final DateFormat dateFormat = DateFormat("MMMM d, HH:mm");

  ReminderList(
      this.reminders,
      this.homePresenter, {
        Key key,
      }) : super(key: key);

  String subtitleConstructor(Reminder reminder){

    if (reminder.date != null){
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(reminder.date);
      return dateFormat.format(date);
    }

    return "";
  }

  void completeReminder(int index) {
    homePresenter.markAsDone(reminders[index]);
    Future.delayed(const Duration(milliseconds: 1000), () {
      homePresenter.delete(reminders[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: reminders == null ? 0 : reminders.length,
      itemBuilder: (BuildContext context, int index) {

        final reminder = reminders[index];

        return new Card(
          child: new InkWell(
              onTap: () {
                edit(reminders[index], context);
              },
              child: new Container(
                  child: new Center(
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: EdgeInsets.all(10.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text(
                                  reminder.text,
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),

                                new Text(
                                  subtitleConstructor(reminder),
                                  style: new TextStyle(
                                      fontSize: 20.0, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Checkbox(
                              value: reminder.done,
                              onChanged: (bool value) => completeReminder(index)
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)
              ),
          )
        );
      }
    );
  }

  edit(Reminder reminder, BuildContext context) {
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => AddReminderPage(true, reminder, homePresenter.updateScreen),
      ),
    );
  }
}
