class Note {
  int? _id;
  late String _title;
  late String _description;
  late String _date;
  late int _priority;
  late int _color;

  // Constructeur principal
  Note(this._title, this._date, this._priority, this._color, [String? description]) {
    _description = description ?? '';
  }

  // Constructeur avec ID (utile pour les updates)
  Note.withId(this._id, this._title, this._date, this._priority, this._color, [String? description]) {
    _description = description ?? '';
  }

  // Getters
  int? get id => _id;
  String get title => _title;
  String get description => _description;
  int get priority => _priority;
  int get color => _color;
  String get date => _date;

  // Setters avec validation
  set title(String newTitle) {
    if (newTitle.length <= 255) {
      _title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 3) {
      _priority = newPriority;
    }
  }

  set color(int newColor) {
    if (newColor >= 0 && newColor <= 9) {
      _color = newColor;
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['color'] = _color;
    map['date'] = _date;
    return map;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map) {
    _id = map['id'];
    _title = map['title'];
    _description = map['description'] ?? '';
    _priority = map['priority'];
    _color = map['color'];
    _date = map['date'];
  }
}
