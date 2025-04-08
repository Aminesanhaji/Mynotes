import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';

class DatabaseHelper {
  static late DatabaseHelper _databaseHelper;
  static Database? _database;
  String noteTable = 'note_table';
  String tagTable = 'tag_table';
  String noteTagTable = 'note_tag_table';

  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';
  String colFavorite = 'isFavorite';

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

    var notesDatabase = await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
      '$colDescription TEXT, $colPriority INTEGER, $colColor INTEGER, $colDate TEXT, $colFavorite INTEGER DEFAULT 0)'
    );

    await db.execute(
      'CREATE TABLE $tagTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)'
    );

    await db.execute(
      'CREATE TABLE $noteTagTable(noteId INTEGER, tagId INTEGER, '
      'FOREIGN KEY(noteId) REFERENCES $noteTable(id), '
      'FOREIGN KEY(tagId) REFERENCES $tagTable(id))'
    );
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tableInfo = await db.rawQuery('PRAGMA table_info($noteTable)');
      final hasFavorite = tableInfo.any((column) => column['name'] == colFavorite);

      if (!hasFavorite) {
        await db.execute('ALTER TABLE $noteTable ADD COLUMN $colFavorite INTEGER DEFAULT 0');
      }

      await db.execute(
        'CREATE TABLE IF NOT EXISTS $tagTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)'
      );

      await db.execute(
        'CREATE TABLE IF NOT EXISTS $noteTagTable(noteId INTEGER, tagId INTEGER, '
        'FOREIGN KEY(noteId) REFERENCES $noteTable(id), '
        'FOREIGN KEY(tagId) REFERENCES $tagTable(id))'
      );
    }
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
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
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x) ?? 0;
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  Future<int> insertTag(String name) async {
    Database db = await database;
    var result = await db.insert(tagTable, {'name': name});
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllTags() async {
    Database db = await database;
    return await db.query(tagTable);
  }

  Future<List<Map<String, dynamic>>> getTagsForNote(int noteId) async {
    Database db = await database;
    return await db.rawQuery(
      'SELECT t.* FROM $tagTable t INNER JOIN $noteTagTable nt ON t.id = nt.tagId WHERE nt.noteId = ?',
      [noteId]
    );
  }

  Future<void> setTagsForNote(int noteId, List<int> tagIds) async {
    Database db = await database;
    await db.delete(noteTagTable, where: 'noteId = ?', whereArgs: [noteId]);
    for (int tagId in tagIds) {
      await db.insert(noteTagTable, {'noteId': noteId, 'tagId': tagId});
    }
  }
}
