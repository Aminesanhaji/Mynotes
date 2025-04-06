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

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper = DatabaseHelper._createInstance(); // Always returns the same instance
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/notes.db';

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
      '$colDescription TEXT, $colPriority INTEGER, $colColor INTEGER, $colDate TEXT)',
    );
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert(noteTable, note.toMap());
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result ?? 0;
  }

  // Get the 'Map List' and convert it to a 'Note List'
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    List<Note> noteList = noteMapList.map((map) => Note.fromMapObject(map)).toList();
    return noteList;
  }
}
