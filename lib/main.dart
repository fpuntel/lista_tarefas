import 'dart:async';
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
  List _toDoList = [];

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
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.amber[800])),
                  ),
                ),
                RaisedButton(
                  color: Colors.amber[800],
                  child: Text("ADD"),
                  textColor: Colors.black,
                  onPressed: () {},
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  // builder é um construtor que permite que construa a lista conforme for rodando
                  // elementos "escondidos" não serão renderizados e com isso não irão
                  // consumir recursos
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length, // tamanho da lista
                  itemBuilder: (context, index){
                      return CheckboxListTile(
                        title: Text(_toDoList[index]["title"]),
                        value: _toDoList[index]["ok"],
                        secondary: CircleAvatar(
                          child: Icon(_toDoList[index]["ok"]?
                              Icons.check: Icons.error
                            ),
                          ),
                      );
                  })),
        ],
      ),
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
