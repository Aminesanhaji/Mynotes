import 'package:flutter/material.dart';
import 'package:notes_app/modal_class/notes.dart';

class NotesSearch extends SearchDelegate<Note?> {
  final List<Note> notes;
  List<Note> filteredNotes = [];

  NotesSearch({required this.notes});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      hintColor: Colors.black,
      primaryColor: Colors.white,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        splashRadius: 22,
        icon: const Icon(
          Icons.clear,
          color: Colors.black,
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      splashRadius: 22,
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(Icons.search, 'Enter a note to search.');
    } else {
      filteredNotes = getFilteredList(notes);
      if (filteredNotes.isEmpty) {
        return _buildEmptyState(Icons.sentiment_dissatisfied, 'No results found');
      } else {
        return _buildNoteList();
      }
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(Icons.search, 'Enter a note to search.');
    } else {
      filteredNotes = getFilteredList(notes);
      if (filteredNotes.isEmpty) {
        return _buildEmptyState(Icons.sentiment_dissatisfied, 'No results found');
      } else {
        return _buildNoteList();
      }
    }
  }

  List<Note> getFilteredList(List<Note> notes) {
    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
      final descMatch = note.description.toLowerCase().contains(query.toLowerCase());
      return titleMatch || descMatch;
    }).toList();
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                icon,
                size: 50,
                color: Colors.black,
              ),
            ),
            Text(
              message,
              style: const TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(
              Icons.note,
              color: Colors.black,
            ),
            title: Text(
              filteredNotes[index].title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              filteredNotes[index].description,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              close(context, filteredNotes[index]);
            },
          );
        },
      ),
    );
  }
}
