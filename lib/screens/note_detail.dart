import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/utils/widgets.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  final DatabaseHelper helper = DatabaseHelper();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  Note note;
  int color = 0;
  bool isEdited = false;
  List<Map<String, dynamic>> tagList = [];
  int? selectedTagId;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  void initState() {
    super.initState();
    titleController.text = note.title;
    descriptionController.text = note.description;
    color = note.color;
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await helper.getAllTags();
    final selectedTags = await helper.getTagsForNote(note.id ?? -1);
    setState(() {
      tagList = tags;
      if (selectedTags.isNotEmpty) {
        selectedTagId = selectedTags.first['id'];
      }
    });
  }
  Future<void> _selectTagDialog() async {
  final TextEditingController tagController = TextEditingController();
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Sélectionner un tag"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...tagList.map((tag) => ListTile(
                  title: Text(tag['name']),
                  leading: Radio<int>(
                    value: tag['id'],
                    groupValue: selectedTagId,
                    onChanged: (value) {
                      setState(() => selectedTagId = value);
                      Navigator.pop(context);
                    },
                  ),
                )),
            const Divider(),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(hintText: 'Créer un nouveau tag'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              final newName = tagController.text.trim();
              if (newName.isNotEmpty) {
                final newId = await helper.createTag(newName);
                await _loadTags(); // <- recharge la liste des tags
                setState(() => selectedTagId = newId); // <- sélectionne le tag nouvellement créé
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Créer et Sélectionner"),
          )
        ],
      ); 
    },
  );
}

/*
  Future<void> _selectTagDialog() async {
    final TextEditingController tagController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sélectionner un tag"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...tagList.map((tag) => ListTile(
                    title: Text(tag['name']),
                    leading: Radio<int>(
                      value: tag['id'],
                      groupValue: selectedTagId,
                      onChanged: (value) {
                        setState(() => selectedTagId = value);
                        Navigator.pop(context);
                      },
                    ),
                  )),
              const Divider(),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(hintText: 'Créer un nouveau tag'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                final newName = tagController.text.trim();
                if (newName.isNotEmpty) {
                  final newId = await helper.createTag(newName);
                  setState(() => selectedTagId = newId);
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text("Créer et Sélectionner"),
            )
          ],
        ); 
      },
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        isEdited ? showDiscardDialog(context) : moveToLastScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(appBarTitle, style: Theme.of(context).textTheme.headlineMedium),
          backgroundColor: colors[color],
          leading: IconButton(
            splashRadius: 22,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              isEdited ? showDiscardDialog(context) : moveToLastScreen();
            },
          ),
          actions: <Widget>[
            if (selectedTagId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    tagList.firstWhere((t) => t['id'] == selectedTagId, orElse: () => {'name': 'No Tag'})['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            IconButton(
              splashRadius: 22,
              icon: const Icon(Icons.label, color: Colors.black),
              tooltip: 'Tag',
              onPressed: _selectTagDialog,
            ),
            IconButton(
              splashRadius: 22,
              icon: const Icon(Icons.save, color: Colors.black),
              onPressed: () {
                titleController.text.isEmpty
                    ? showEmptyTitleDialog(context)
                    : _save();
              },
            ),
            IconButton(
              splashRadius: 22,
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () => showDeleteDialog(context),
            )
          ],
        ),
        body: Container(
          color: colors[color],
          child: Column(
            children: <Widget>[
              PriorityPicker(
                selectedIndex: 3 - note.priority,
                onTap: (index) {
                  isEdited = true;
                  note.priority = 3 - index;
                },
              ),
              ColorPicker(
                selectedIndex: note.color,
                onTap: (index) {
                  setState(() => color = index);
                  isEdited = true;
                  note.color = index;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: titleController,
                  maxLength: 255,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) => updateTitle(),
                  decoration: const InputDecoration.collapsed(hintText: 'Titre'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    maxLength: 255,
                    controller: descriptionController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (value) => updateDescription(),
                    decoration: const InputDecoration.collapsed(hintText: 'Description'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    isEdited = true;
    note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());

    if (note.id != null) {
      await helper.updateNote(note);
    } else {
      note.id = await helper.insertNote(note);
    }

    if (selectedTagId != null && note.id != null) {
      await helper.removeTagsFromNote(note.id!);
      await helper.assignTagToNote(note.id!, selectedTagId!);
    }
  }

  void _delete() async {
    await helper.deleteNote(note.id!);
    moveToLastScreen();
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text("Annuler les modifications ?", style: Theme.of(context).textTheme.bodyMedium),
          content: Text("Voulez-vous vraiment annuler ?", style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              child: Text("Non", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purple)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Oui", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text("Titre vide !", style: Theme.of(context).textTheme.bodyMedium),
          content: Text("Le titre de la note ne peut pas être vide.", style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              child: Text("Ok", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purple)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text("Supprimer la note ?", style: Theme.of(context).textTheme.bodyMedium),
          content: Text("Êtes-vous sûr ?", style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              child: Text("Non", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purple)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Oui", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
              },
            ),
          ],
        );
      },
    );
  }
}
