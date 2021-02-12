class Reminder {

  int id;
  String _text;
  int _date;
  bool done = false;

  Reminder(this._text, this._date);

  Reminder.map(dynamic obj) {
    this._text = obj["text"];
    this._date = obj["date"];
  }

  String get text => _text;
  int get date => _date;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["text"] = _text;
    map["date"] = _date;
    return map;
  }

  void setReminderId(int id) {
    this.id = id;
  }

  int notificationId() {
    if (_date != null && id != null) {
      final date = new DateTime.fromMillisecondsSinceEpoch(_date);
      return date.millisecondsSinceEpoch~/1000 + id;
    }
  }
}
