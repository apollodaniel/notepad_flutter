import 'package:aprendendo_sql/model/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase{

  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;

  NotesDatabase._init();

  factory NotesDatabase(){
    return instance;
  }


  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await _initDB('notes.db');

    return _database!;
  }
  _initDB(String filepath) async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path,version: 1, onCreate: _createDB);

  }
  Future _createDB(Database db, int version) async{
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    await db.execute("CREATE TABLE $tableNotes (${NoteFields.id} $idType, ${NoteFields.title} VARCHAR, ${NoteFields.description} TEXT, ${NoteFields.date} TEXT) ");
  }

  Future<int> insertNote(Note note) async {
    Database db = await instance.database;

    int id = await db.insert(tableNotes, note.toMap());

    return id;
  }

  updateNote(Note note, String old_date)async{
    Database db = await instance.database;
    int result = await db.update(tableNotes, note.toMap(),  where: "date = ?", whereArgs: [old_date]);
    return result;
  }

  Future<List> getNotes() async {
   String sql = "SELECT * FROM $tableNotes ORDER BY ${NoteFields.id} DESC";
   Database db = await instance.database;
   List result = await db.rawQuery(sql);
   return result;
  }

  deleteNote(String date) async{
    Database db = await instance.database;
    int result = await db.delete(tableNotes, where: "date = ?", whereArgs: [date]);
    return result;
  }

  Future close() async{
    final db = await instance.database;
    db.close();
  }


}