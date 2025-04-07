import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';

class DatabaseHelper {
  static late DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';
  String colIsFavorite = 'isFavorite';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper = DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/notes.db';

    await deleteDatabase(path); // ⚠️ TEMPORAIRE — à retirer après la première exécution

    var notesDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, '
      '$colColor INTEGER, $colDate TEXT, $colIsFavorite INTEGER)'
    );
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert(noteTable, note.toMap());
  }

  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
  }

  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result ?? 0;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    List<Note> noteList = noteMapList.map((map) => Note.fromMapObject(map)).toList();
    return noteList;
  }
}