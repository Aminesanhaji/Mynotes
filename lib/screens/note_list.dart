import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_app/screens/change_password.dart';

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
  bool isFilteredByFavorite = false;
  int? priorityFilter; // 1 (!!!), 2 (!!), 3 (!)

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
                final Note? result = await showSearch<Note?> (
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Tous') {
                    setState(() {
                      isFilteredByFavorite = false;
                      priorityFilter = null;
                    });
                    updateListView();
                  } else if (value == 'Favoris') {
                    setState(() {
                      isFilteredByFavorite = true;
                      priorityFilter = null;
                      noteList = noteList.where((n) => n.isFavorite).toList();
                      count = noteList.length;
                    });
                  } else {
                    int selectedPriority = 3; // default !
                    if (value == 'High') selectedPriority = 2;
                    if (value == 'Very High') selectedPriority = 1;

                    setState(() {
                      isFilteredByFavorite = false;
                      priorityFilter = selectedPriority;
                      noteList = noteList.where((n) => n.priority == selectedPriority).toList();
                      count = noteList.length;
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    'Tous',
                    'Favoris',
                    'Low',
                    'High',
                    'Very High'
                  ].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFilteredByFavorite || priorityFilter != null
                            ? 'Aucune note trouvée.'
                            : 'Clique sur le + pour ajouter une note !',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFilteredByFavorite = false;
                            priorityFilter = null;
                          });
                          updateListView();
                        },
                        child: const Text('Retour à toutes les notes'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('❗️ Low', style: TextStyle(fontSize: 12)),
                      Text('❗️❗️ High', style: TextStyle(fontSize: 12)),
                      Text('❗️❗️❗️ Very High', style: TextStyle(fontSize: 12)),
                      Text('❤️ Favori', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(child: buildGroupedNotes()),
              ],
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

  Widget buildGroupedNotes() {
    final priorities = [1, 2, 3];
    final labels = {
      1: 'Very High',
      2: 'High',
      3: 'Low',
    };
    final filtered = <int, List<Note>>{};
    for (var p in priorities) {
      filtered[p] = noteList.where((note) => note.priority == p).toList();
    }

    return ListView(
      children: priorities.map((priority) {
        final notes = filtered[priority]!;
        if (notes.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                labels[priority]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MasonryGridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: axisCount,
              shrinkWrap: true,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                final note = notes[index];
                return GestureDetector(
                  onTap: () {
                    navigateToDetail(note, 'Edit Note');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: colors[note.color],
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    note.title,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    getPriorityText(note.priority),
                                    style: TextStyle(
                                      color: getPriorityColor(note.priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      note.isFavorite = !note.isFavorite;
                                      await databaseHelper.updateNote(note);
                                      updateListView();
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    note.description ?? '',
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
                                note.date,
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
            )
          ],
        );
      }).toList(),
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
