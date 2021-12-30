import 'package:aprendendo_sql/helper/notes_database.dart';
import 'package:aprendendo_sql/model/note.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  var _db = NotesDatabase();

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  TextEditingController _editarTituloController = TextEditingController();
  TextEditingController _editarDescricaoController = TextEditingController();

  List<Note> _notes = [];

  _recuperarNotas() async {
    List resultado = await _db.getNotes();

    List<Note> notes = [];

    for (var i in resultado) {
      Note note = Note(
          title: i[NoteFields.title],
          description: i[NoteFields.description],
          date: i[NoteFields.date]);
      notes.add(note);
    }

    setState(() {
      _notes = notes;
    });

    notes = [];
  }

  _editarNotaDB(int index, String titulo, String descricao, String date)async {
    String old_date = _notes[index].date;
    int id = await _db.updateNote(titulo, descricao, date, old_date);

    _recuperarNotas();
  }

  _adicionarNota() async {
    String _titulo = _tituloController.text;
    String _descricao = _descricaoController.text;

    int result = await _db.insertNote(Note(
        title: _titulo,
        description: _descricao,
        date: DateTime.now().toString()));
    print("Resultado/id = $result");

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarNotas();
  }

  _editarNota(int index){

    _editarTituloController.text = _notes[index].title;
    _editarDescricaoController.text = _notes[index].description;

    showDialog(
        context: context,
        builder: (context_dialog) {
          return AlertDialog(
            title: Text("Editar nota"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editarTituloController,
                  decoration: InputDecoration(
                      label: Text("Título")),
                ),
                TextField(
                    controller: _editarDescricaoController,
                    decoration: InputDecoration(
                        label: Text("Descrição")
                    ))

              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    if (_editarTituloController.text.isEmpty || _editarDescricaoController.text.isEmpty) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.warning),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                    "O título e descrição não podem estar vazios!"),
                              )
                            ],
                          )));
                      Navigator.pop(context_dialog);
                    } else {
                      _editarNotaDB(index, _editarTituloController.text, _editarDescricaoController.text, DateTime.now().toString());
                    }
                    _editarTituloController.clear();
                    _editarDescricaoController.clear();
                    Navigator.pop(context_dialog);
                  },
                  child: Text("Salvar")),
              FlatButton(
                  onPressed: () {
                    _editarTituloController.clear();
                    _editarDescricaoController.clear();
                    Navigator.pop(context_dialog);
                  },
                  child: Text("Cancelar"))
            ],
          );
        },
    );


  }

  _deletarNota(int index){

  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    DateTime date = DateTime.parse(data);
    var formatter = DateFormat.yMd("pt_BR");

    String data_formatada = formatter.format(date).toString();
    return data_formatada;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _db.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarNotas();
  }

  @override
  Widget build(BuildContext context) {
    //adicionarNota();
    return Scaffold(
      appBar: AppBar(
        title: Text("Aprendendo sqlite!"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return Dismissible(
                onDismissed: (direction) {
                  switch (direction) {
                    case DismissDirection.endToStart:
                      //print("Editar");
                      _editarNota(index);
                      break;
                    case DismissDirection.startToEnd:
                      //print("Deletar");
                      _deletarNota(index);
                      break;
                    case DismissDirection.vertical:
                      // TODO: Handle this case.
                      break;
                    case DismissDirection.horizontal:
                      // TODO: Handle this case.
                      break;
                    case DismissDirection.up:
                      // TODO: Handle this case.
                      break;
                    case DismissDirection.down:
                      // TODO: Handle this case.
                      break;
                    case DismissDirection.none:
                      // TODO: Handle this case.
                      break;
                  }
                },
                background: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text("Deletar",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.green,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text("Editar",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                child: ListTile(
                  title: Text(_notes[index].title),
                  subtitle: Text(
                      "${_formatarData(_notes[index].date)} - ${_notes[index].description}"),
                ));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            builder: (context_dialog) {
              return AlertDialog(
                title: Text("Adicionar nota"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                          labelText: "Título", hintText: "Digite um título"),
                    ),
                    TextField(
                        controller: _descricaoController,
                        decoration: InputDecoration(
                            labelText: "Descrição",
                            hintText: "Digite uma descrição"))
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Row(
                            children: [
                              Icon(Icons.warning),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                    "O título e descrição não podem estar vazios!"),
                              )
                            ],
                          )));
                          Navigator.pop(context_dialog);
                        } else {
                          _adicionarNota();
                        }
                        Navigator.pop(context_dialog);
                      },
                      child: Text("Salvar")),
                  FlatButton(
                      onPressed: () {
                        _tituloController.clear();
                        _descricaoController.clear();
                        Navigator.pop(context_dialog);
                      },
                      child: Text("Cancelar"))
                ],
              );
            },
            context: context,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
