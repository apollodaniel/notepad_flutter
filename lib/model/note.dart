
final String tableNotes = 'notes';

class NoteFields{
  static final String id = "id";
  static final String description = "description";
  static final String title = "title";
  static final String date = "date";
}

class Note{

  final int? id;
  final String title;
  final String description;
  final String date;

  const Note({
    this.id,
    required this.title,
    required this.description,
    required this.date
  });

  toMap(){
    Map<String, dynamic> map = Map();

    if(this.id != null) map[NoteFields.id] = this.id;

    map[NoteFields.title] = title;
    map[NoteFields.description] = description;
    map[NoteFields.date] = date;

    return map;
  }

}