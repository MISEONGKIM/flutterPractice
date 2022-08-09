import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_example_flutter/todo.dart';

class AddTodoApp extends StatefulWidget {
  final Future<Database> db;
  const AddTodoApp(this.db, {Key? key}) : super(key: key);
@override 
State<StatefulWidget> createState() => _AddTodoApp();
}

class _AddTodoApp extends State<StatefulWidget> {
  TextEditingController? titleController;
  TextEditingController? contentController;

  @override 
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 추가'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(controller: contentController,
                decoration: const InputDecoration(labelText: '할일'),
                ),
              ),
             ElevatedButton(
               onPressed: () {
                 Todo todo = Todo(title: titleController?.value.text, content: contentController?.value.text, active: false);
                 Navigator.of(context).pop(todo);
               },
               child: const Text('저장하기'),
             )
            ],
          ),
        ),
      ),
    );
  }

}


