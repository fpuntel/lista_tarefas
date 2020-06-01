import 'dart:async';
//import 'dart:html';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Json - file

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

// stful
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];

  // Mapa que acabamos de remover
  Map<String, dynamic> _lastRemoved;
  // Qual posicao foi removido
  int _lastRemovedPos;

  // Função chamada quando inicia o app
  @override
  void initState() {
    super.initState();
    /*
      .then utilizado para que quando a função
      _readData concluir será chamada a outra função
     */
    _readData().then((data) {
      /*
        _readData retorna um json e quando concluído
        será decodificado no _toDoList
        Utilizado o setState para atualizar a tela
      */
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      // Pegar texto do textfield
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = ""; // limpar texto
      newToDo["ok"] = false; // tarefa inicia como "nao realizada"
      _toDoList.add(newToDo); // adiciona tarefa na lista
      _saveData(); // Salva os dados na memória
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    // necessita ter dois argumentos
    // a > b = retorna 1
    // a == b = retorna 0
    // a < b = numero negativo
    _toDoList.sort((a, b){ 
      if(a["ok"] && !b["ok"])return 1;
      else if(!a["ok"] && b["ok"])return -1;
      else return 0;
    });

    // Atualiza a lista
    setState(() {
      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.amber[800],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            // Espaçamento nas laterais
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.amber[800])),
                  ),
                ),
                RaisedButton(
                  color: Colors.amber[800],
                  child: Text("ADD"),
                  textColor: Colors.black,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                  child: ListView.builder(
                      // builder é um construtor que permite que construa a lista conforme for rodando
                      // elementos "escondidos" não serão renderizados e com isso não irão
                      // consumir recursos
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _toDoList.length, // tamanho da lista
                      itemBuilder: buildItem),
                  onRefresh: _refresh)),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    // Dismissible permite que excluimos o item
    return Dismissible(
      // key: String que vai definir qual dos itens foi excluido
      // essa key deve ser diferente em cada um dos itens
      // por isso utiliza a data agora em milissegundos
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          // Parametros de Alignment:
          // x e y devem receber a distancia para a esquerda
          // e direita que o  item vai ficar.
          // Valor de entre -1 a 1.
          // Se passar 0 e 0 item fica no meio
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd, // da esquerda para direita
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          backgroundColor: Colors.amber[800],
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check : Icons.error,
            color: Colors.black,
          ),
        ),
        // Chamado quando clicado no elemento da lista:
        onChanged: (c) {
          setState(() {
            // Armazena no index ok
            _toDoList[index]["ok"] = c;
            // Salva dados quando atualizado algum item na lista
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          // Primeiramente salva o item que será removido
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          // Remove item da lista
          _toDoList.removeAt(index);
          // Salva lista com item removido
          _saveData();

          // snackbar informando a remoção do item
          final snack = SnackBar(
            content: Text("Tarefa " + _lastRemoved["title"] + " removida"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    // Adiciona na posição que estava
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          // Remove snackbar da pilha antes de mostrar a nova
          Scaffold.of(context).removeCurrentSnackBar(); 

          // Para apresentar o snackbar
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  // Get file and directory
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

// SaveData in file
  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  // Read data in file
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
