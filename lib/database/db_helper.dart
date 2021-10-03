import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_with_nullsafety/models/note_model.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _db = null;

  DatabaseHelper._instance();

  String databaseName = 'todo_list.db';
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  /*Looks like something like this
  * id | Title | Date | Priority | Status
  * 0    ""      ""      ""         0
  * 1    "       "       ""         1
  *
  *
  */

  Future<Database?> get db async {
    _db ??= await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    io.Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var todoListDB = await openDatabase(path, version: 1, onCreate: _create);

    return todoListDB;
  }

  void _create(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $noteTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "$colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)");
  }

  Future<List<Map<String, dynamic>>> getNoteMap() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(noteTable);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    // List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<Map<String, dynamic>> noteMapList = await getNoteMap();
    final List<Note> noteList = [];
    noteMapList.forEach((noteMap) {
      noteList.add(Note.fromMap(noteMap));
    });
    noteList.sort((noteA, noteB) => noteA.date!.compareTo(noteB.date!));
    return noteList;
  }

  Future<int> insertNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.insert(
      noteTable,
      note.toMap(),
    );
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.update(
      noteTable,
      note.toMap(),
      where: "$colId = ?",
      whereArgs: [note.id],
    );
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
      noteTable,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }



// Future close() async {
//   var dbClient = await db;
//   dbClient.close();
// }
}
