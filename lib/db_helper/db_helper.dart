import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';

class DatabaseHelper {
  static late DatabaseHelper _databaseHelper;
  static Database? _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';
  String colIsFavorite = 'isFavorite';
  String colIsPrivate = 'isPrivate';

  String tagTable = 'tag_table';
  String colTagId = 'id';
  String colTagName = 'name';

  String noteTagTable = 'note_tag_table';
  String colNoteId = 'note_id';
  String colTagRefId = 'tag_id';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper = DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/notes.db';

    var notesDatabase = await openDatabase(path,
        version: 2, onCreate: _createDb, onUpgrade: _onUpgrade);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''CREATE TABLE $noteTable(
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colTitle TEXT,
      $colDescription TEXT,
      $colPriority INTEGER,
      $colColor INTEGER,
      $colDate TEXT,
      $colIsFavorite INTEGER,
      $colIsPrivate INTEGER)''');

    await db.execute('''CREATE TABLE $tagTable(
      $colTagId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colTagName TEXT)''');

    await db.execute('''CREATE TABLE $noteTagTable(
      $colNoteId INTEGER,
      $colTagRefId INTEGER,
      FOREIGN KEY($colNoteId) REFERENCES $noteTable($colId),
      FOREIGN KEY($colTagRefId) REFERENCES $tagTable($colTagId))''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $noteTable ADD COLUMN $colIsFavorite INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE $noteTable ADD COLUMN $colIsPrivate INTEGER DEFAULT 0");
    }
  }

  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    var db = await database;
    return await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
  }

  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) from $noteTable');
    return Sqflite.firstIntValue(x) ?? 0;
  }

  Future<List<Note>> getNoteList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(noteTable, orderBy: '$colPriority ASC');
    return List.generate(maps.length, (i) => Note.fromMapObject(maps[i]));
  }

  // ---------------- TAGS ----------------

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return await db.query(tagTable);
  }

  Future<List<Map<String, dynamic>>> getTagsForNote(int noteId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.* FROM $tagTable t
      INNER JOIN $noteTagTable nt ON t.$colTagId = nt.$colTagRefId
      WHERE nt.$colNoteId = ?
    ''', [noteId]);
  }

  Future<void> assignTagToNote(int noteId, int tagId) async {
    final db = await database;
    await db.insert(noteTagTable, {
      colNoteId: noteId,
      colTagRefId: tagId,
    });
  }

  Future<void> removeTagsFromNote(int noteId) async {
    final db = await database;
    await db.delete(noteTagTable, where: '$colNoteId = ?', whereArgs: [noteId]);
  }

  Future<int> createTag(String name) async {
    final db = await database;
    return await db.insert(tagTable, {colTagName: name});
  }
}