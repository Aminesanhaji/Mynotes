class Note {
  int? _id;
  String _title;
  String _description;
  String _date;
  int _priority, _color;
  bool _isFavorite;
  bool _isPrivate;

  // Constructeur principal
  Note(this._title, this._date, this._priority, this._color,
      {String description = '', bool isFavorite = false, bool isPrivate = false})
      : _description = description,
        _isFavorite = isFavorite,
        _isPrivate = isPrivate;

  // Constructeur avec ID
  Note.withId(this._id, this._title, this._date, this._priority, this._color,
      {String description = '', bool isFavorite = false, bool isPrivate = false})
      : _description = description,
        _isFavorite = isFavorite,
        _isPrivate = isPrivate;

  // Getters
  int? get id => _id;
  String get title => _title;
  String get description => _description;
  int get priority => _priority;
  int get color => _color;
  String get date => _date;
  bool get isFavorite => _isFavorite;
  bool get isPrivate => _isPrivate;

  // Setters
  set id(int? id) => _id = id;
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

  set isFavorite(bool fav) => _isFavorite = fav;
  set isPrivate(bool priv) => _isPrivate = priv;

  // Convertir une Note en Map
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
    map['isFavorite'] = _isFavorite ? 1 : 0;
    map['isPrivate'] = _isPrivate ? 1 : 0;
    return map;
  }

  // Créer une Note depuis un Map
  Note.fromMapObject(Map<String, dynamic> map)
      : _id = map['id'],
        _title = map['title'],
        _description = map['description'],
        _priority = map['priority'],
        _color = map['color'],
        _date = map['date'],
        _isFavorite = map['isFavorite'] == 1,
        _isPrivate = map['isPrivate'] == 1;
}
