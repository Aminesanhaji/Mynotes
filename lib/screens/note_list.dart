import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/screens/change_password.dart'; // 👈 import ajouté

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;
  int axisCount = 2;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  PreferredSizeWidget myAppBar() {
    return AppBar(
      title: Text('Notes', style: Theme.of(context).textTheme.headlineMedium),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: noteList.isEmpty
          ? Container()
          : IconButton(
              splashRadius: 22,
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () async {
                final Note? result = await showSearch<Note?>(
                  context: context,
                  delegate: NotesSearch(notes: noteList),
                );
                if (result != null) {
                  navigateToDetail(result, 'Edit Note');
                }
              },
            ),
      actions: <Widget>[
        if (!noteList.isEmpty)
          Row(
            children: [
              IconButton(
                splashRadius: 22,
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                splashRadius: 22,
                icon: Icon(
                  axisCount == 2 ? Icons.list : Icons.grid_on,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    axisCount = axisCount == 2 ? 4 : 2;
                  });
                },
              ),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      body: noteList.isEmpty
          ? Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Click on the add button to add a new note!',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: getNotesList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0), 'Add Note');
        },
        tooltip: 'Add Note',
        shape: const CircleBorder(
            side: BorderSide(color: Colors.black, width: 2.0)),
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget getNotesList() {
    return MasonryGridView.count(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: axisCount,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            navigateToDetail(noteList[index], 'Edit Note');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: colors[noteList[index].color],
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            noteList[index].title,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Text(
                        getPriorityText(noteList[index].priority),
                        style: TextStyle(
                            color: getPriorityColor(noteList[index].priority)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            noteList[index].description ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        noteList[index].date,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
      case 2:
        return '!!';
      case 3:
        return '!';
      default:
        return '!';
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }
}
