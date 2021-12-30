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

  updateNote(String title, String description, String date, String old_date)async{
    Database db = await instance.database;

    String sql = "UPDATE $tableNotes SET ${NoteFields.title} = $title, ${NoteFields.description} = $description, ${NoteFields.date} = '$date' WHERE ${NoteFields.date} = '$old_date'";

    int result = await db.rawUpdate(sql);

    print("s");
    return result;
  }

  Future<List> getNotes() async {
   String sql = "SELECT * FROM $tableNotes ORDER BY ${NoteFields.id} DESC";
   Database db = await instance.database;
   List result = await db.rawQuery(sql);
   return result;
  }

  Future close() async{
    final db = await instance.database;
    db.close();
  }


}