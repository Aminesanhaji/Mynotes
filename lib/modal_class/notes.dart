class Note {
  int? _id;
  String _title;
  String _description;
  String _date;
  int _priority, _color;
  bool isFavorite;
  List<int> tagIds = [];

  Note(this._title, this._date, this._priority, this._color,
      [this._description = '', this.isFavorite = false]);

  Note.withId(this._id, this._title, this._date, this._priority, this._color,
      [this._description = '', this.isFavorite = false]);

  int? get id => _id;

  set id(int? id) {
    _id = id;
  }

  String get title => _title;
  String get description => _description;
  int get priority => _priority;
  int get color => _color;
  String get date => _date;

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

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['color'] = _color;
    map['date'] = _date;
    map['isFavorite'] = isFavorite ? 1 : 0;
    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map)
      : _id = map['id'],
        _title = map['title'],
        _description = map['description'],
        _priority = map['priority'],
        _color = map['color'],
        _date = map['date'],
        isFavorite = map['isFavorite'] == 1;
}
