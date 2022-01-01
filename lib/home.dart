import 'package:aprendendo_sql/helper/notes_database.dart';
import 'package:aprendendo_sql/model/note.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  var _db = NotesDatabase();

  final _appTitle = "Anotações";

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  List<Note> _notes = <Note>[];

  _recuperarNotas() async {
    List resultado = await _db.getNotes();

    List<Note> notes = <Note>[];

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
  }

  _mostrarTelaCadastro({Note? note, required int index}) {
    String _actionName = "";

    bool isAtualizar = false;

    if (note == null) {
      // salvar
      _actionName = "Salvar";
      _tituloController.clear();
      _descricaoController.clear();
    } else {
      // editar
      isAtualizar = true;
      _actionName = "Atualizar";
      _tituloController.text = note.title;
      _descricaoController.text = note.description;
    }

    showDialog(
      context: context,
      builder: (context_dialog) {
        return AlertDialog(
          title: Text("$_actionName nota"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(label: Text("Título")),
              ),
              TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(label: Text("Descrição")))
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  // confirmar
                  _adicionarNota(isAtualizar: isAtualizar, index: index);
                  Navigator.pop(context_dialog);
                },
                child: Text(_actionName)),
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
    );
  }

  _adicionarNota({required bool isAtualizar, required int index}) async {
    if (isAtualizar) {
      //editar

      Note note = Note(
          title: _tituloController.text,
          description: _descricaoController.text,
          date: DateTime.now().toString());
      int id = await _db.updateNote(note, _notes[index].date);
      print("ID: $id");
    } else {
      //salvar
      String _titulo = _tituloController.text;
      String _descricao = _descricaoController.text;

      int result = await _db.insertNote(Note(
          title: _titulo,
          description: _descricao,
          date: DateTime.now().toString()));
      print("Resultado/id = $result");
    }

    _tituloController.clear();
    _descricaoController.clear();
    _recuperarNotas();
  }

  _deletarNota(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Row(
              children: [
                Icon(Icons.warning),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Aviso"),
                )
              ],
            ),
          ),
          content: Text("Você realmente deseja apagar a nota \"${_notes[index].title}\"?"),
          contentPadding: EdgeInsets.all(32),
          actions: [

            FlatButton(
                onPressed: (){
                  _recuperarNotas();
                  Navigator.pop(context);
                },
                child: Text("Cancelar")
            ),
            FlatButton(
                onPressed: () async {
                  int result = await _db.deleteNote(_notes[index].date.toString());
                  _recuperarNotas();
                  Navigator.pop(context);
                  print('nota deletada $result');
                },
                child: Text("Apagar")
            ),
          ],
        );
      },
    );


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
        title: Text(_appTitle),
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
                      _mostrarTelaCadastro(note: _notes[index], index: index);
                      _recuperarNotas();
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
                        if (_tituloController.text.isEmpty ||
                            _descricaoController.text.isEmpty) {
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
                          _adicionarNota(isAtualizar: false, index: 0);
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
