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
import 'package:shared_preferences/shared_preferences.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> fullNoteList = [];
  List<Note> noteList = [];
  List<Map<String, dynamic>> tagList = [];
  int count = 0;
  int axisCount = 2;
  bool isFilteredByFavorite = false;
  int? priorityFilter;
  int? tagFilter;
  bool showPrivateNotes = false;

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
              icon: const Icon(Icons.search, color: Colors.black),
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
        if (noteList.isNotEmpty)
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
                  showPrivateNotes ? Icons.lock_open : Icons.lock_outline,
                  color: Colors.black,
                ),
                tooltip: 'Afficher les notes privées',
                onPressed: () => showPrivateNotes
                    ? setState(() => showPrivateNotes = false)
                    : _promptPassword(context),
              ),
              IconButton(
                icon: const Icon(Icons.label_outline, color: Colors.black),
                tooltip: "Filtrer par tag",
                onPressed: () => _showTagFilterDialog(),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    isFilteredByFavorite = false;
                    priorityFilter = null;
                    tagFilter = null;
                    noteList = List.from(fullNoteList);
                  });

                  if (value == 'Favoris') {
                    setState(() {
                      isFilteredByFavorite = true;
                      noteList = fullNoteList.where((n) => n.isFavorite).toList();
                      count = noteList.length;
                    });
                  } else if (value == 'Low') {
                    setState(() {
                      priorityFilter = 3;
                      noteList = fullNoteList.where((n) => n.priority == 3).toList();
                      count = noteList.length;
                    });
                  } else if (value == 'High') {
                    setState(() {
                      priorityFilter = 2;
                      noteList = fullNoteList.where((n) => n.priority == 2).toList();
                      count = noteList.length;
                    });
                  } else if (value == 'Very High') {
                    setState(() {
                      priorityFilter = 1;
                      noteList = fullNoteList.where((n) => n.priority == 1).toList();
                      count = noteList.length;
                    });
                  } else {
                    updateListView();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return ['Tous', 'Favoris', 'Low', 'High', 'Very High']
                      .map((String choice) => PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          ))
                      .toList();
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

  Future<void> _promptPassword(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('private_password') ?? '';
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mot de passe des notes privées'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Entrez votre mot de passe'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (controller.text == savedPassword) {
                Navigator.pop(context);
                setState(() => showPrivateNotes = true);
                updateListView();
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mot de passe incorrect'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTagFilterDialog() async {
    tagList = await databaseHelper.getAllTags();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filtrer par tag"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tagList.length,
              itemBuilder: (context, index) {
                final tag = tagList[index];
                return ListTile(
                  title: Text(tag['name']),
                  onTap: () async {
                    tagFilter = tag['id'];
                    final allNotes = await databaseHelper.getNoteList();
                    List<Note> filtered = [];
                    for (final note in allNotes) {
                      final tags = await databaseHelper.getTagsForNote(note.id!);
                      final tagIds = tags.map((e) => e['id']).toList();
                      if (tagIds.contains(tagFilter)) {
                        filtered.add(note);
                      }
                    }
                    setState(() {
                      noteList = filtered;
                      count = filtered.length;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                tagFilter = null;
                updateListView();
                Navigator.of(context).pop();
              },
              child: const Text("Réinitialiser"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      body: noteList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isFilteredByFavorite || priorityFilter != null || tagFilter != null
                        ? 'Aucune note trouvée.'
                        : 'Clique sur le + pour ajouter une note !',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (isFilteredByFavorite || priorityFilter != null || tagFilter != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFilteredByFavorite = false;
                          priorityFilter = null;
                          tagFilter = null;
                        });
                        updateListView();
                      },
                      child: const Text('Retour à toutes les notes'),
                    ),
                ],
              ),
            )
          : buildGroupedNotesWithDrag(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0, isPrivate: false), 'Add Note');
        },
        tooltip: 'Add Note',
        shape: const CircleBorder(
            side: BorderSide(color: Colors.black, width: 2.0)),
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget buildGroupedNotesWithDrag() {
    final priorities = [1, 2, 3];
    final labels = {1: 'Very High', 2: 'High', 3: 'Low'};

    return ListView(
      children: priorities.map((priority) {
        final notes = noteList.where((note) => note.priority == priority).toList();
        if (notes.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(labels[priority]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            DragTarget<Note>(
              onWillAccept: (incoming) => true,
              onAccept: (incomingNote) async {
                incomingNote.priority = priority;
                await databaseHelper.updateNote(incomingNote);
                updateListView();
              },
              builder: (context, candidateData, rejectedData) {
                return Wrap(
                  children: notes.map((note) => buildDraggableNote(note)).toList(),
                );
              },
            )
          ],
        );
      }).toList(),
    );
  }

  Widget buildDraggableNote(Note note) {
    return LongPressDraggable<Note>(
      data: note,
      feedback: Material(
        color: Colors.transparent,
        child: noteCard(note),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: noteCard(note)),
      child: noteCard(note),
    );
  }

  Widget noteCard(Note note) {
    return GestureDetector(
      onTap: () => navigateToDetail(note, 'Edit Note'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors[note.color],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2, color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(note.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (note.isPrivate)
                  const Icon(Icons.lock, size: 18, color: Colors.black),
                IconButton(
                  icon: Icon(
                    note.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 18,
                  ),
                  onPressed: () async {
                    note.isFavorite = !note.isFavorite;
                    await databaseHelper.updateNote(note);
                    updateListView();
                  },
                )
              ],
            ),
            const SizedBox(height: 4),
            Text(note.description ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 3),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getPriorityText(note.priority),
                    style: TextStyle(
                        color: getPriorityColor(note.priority), fontWeight: FontWeight.bold)),
                Text(note.date,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetail(note, title)),
    );
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
          fullNoteList = noteList;
          this.noteList = noteList.where((n) => showPrivateNotes || !n.isPrivate).toList();
          count = this.noteList.length;
        });
      });
    });
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
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
}