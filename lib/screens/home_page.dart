import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_with_nullsafety/database/db_helper.dart';
import 'package:todo_with_nullsafety/models/note_model.dart';
import 'package:todo_with_nullsafety/screens/add_update.dart';
import 'package:todo_with_nullsafety/screens/pop_up_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy");
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _databaseHelper.getNoteList();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget _buildListNodes(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3.0,
        color: Colors.cyan,
        child: ListTile(
          title: Text(
            note.title!,
            style: TextStyle(
                color: note.status == 0 ? Colors.black : Colors.pink,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                onChanged: (value) {
                  setState(() {
                    note.status = value! ? 1 : 0;
                  });
                  DatabaseHelper.instance.updateNote(note);
                  _updateNoteList;
                },
                activeColor: Theme.of(context).primaryColor,
                value: note.status == 1 ? true : false,
              ),
              GestureDetector(
                  child: const Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    _databaseHelper.deleteNote(note.id!);
                    setState(() {
                      _updateNoteList();
                    });
                  }),
              FavoriteButton(
                iconSize: 35,
                isFavorite: true,
                iconDisabledColor: Colors.white,
                iconColor: Colors.green,
                valueChanged: (_isFavorite) {
                  print('Is Favorite : $_isFavorite');
                },
              ),
              StarButton(
                isStarred: false,
                // iconDisabledColor: Colors.white,
                valueChanged: (_isStarred) {
                  print('Is Starred : $_isStarred');
                },
              ),
            ],
          ),
          onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => AddNote(
                        updateNoteList: _updateNoteList(),
                        note: note,
                      ))),
          subtitle:
              Text("${_dateFormat.format(note.date!)} * ${note.priority}"),
        ),
      ),
    );
  }

  // Widget _buildPopupDialog(BuildContext context) {
  //   return AlertDialog(
  //     title: const Text('Popup example'),
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text("Hello"),
  //       ],
  //     ),
  //     actions: <Widget>[
  //       FlatButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //         textColor: Theme.of(context).primaryColor,
  //         child: const Text('Close'),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            elevation: 3.5,
            centerTitle: true,
            titleSpacing: 2.0,
            backgroundColor: Colors.deepPurpleAccent,
            title: const Text(
              "ToDo App",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => PopUpWindow(updateNoteList: _updateNoteList),
                );
                // Navigator.push(
                //     context,
                //     CupertinoPageRoute(
                //         builder: (_) => AddNote(
                //           updateNoteList: _updateNoteList,
                //         )));
              },
              elevation: 3.2,
              backgroundColor: Colors.deepPurple,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 40.5,
              ),
              tooltip: "Add note"),
          body: FutureBuilder(
            future: _noteList,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final int completeNoteCount = snapshot.data!
                  .where((Note note) => note.status == 1)
                  .toList()
                  .length;
              return ListView.builder(
                itemCount: int.parse(snapshot.data!.length.toString()) + 1,
                padding: const EdgeInsets.symmetric(vertical: 15),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "My Notes",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 25),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                  "$completeNoteCount of ${snapshot.data.length}",
                                  style: const TextStyle(color: Colors.black))
                            ]));
                  }
                  return _buildListNodes(snapshot.data![index - 1]);
                },
              );
            },
          )),
    );
  }
}
