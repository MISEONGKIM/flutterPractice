import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_example_flutter/todo.dart';

import 'addTodo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<Database> database = initDatabase();
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/' : (context) => DatabaseApp(database),
        '/add' : (context) => AddTodoApp(database),
      },
    );
  }

  Future<Database> initDatabase() async {
    
    String sql = 'CREATE TABLE todos( ' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        'title TEXT,' +
        'content TEXT,' +
        'active BOOL)';

    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) { //todo_database.db 파일에 테이블이 없으면 새로운 db 생성.
        return db.execute(sql);
      },
      version: 1,
    );
  }
}

class DatabaseApp extends StatefulWidget {
  final Future<Database> db;
   const DatabaseApp(this.db, {Key? key}) : super(key: key);
  @override 
  State<StatefulWidget> createState() => _DatabaseApp();
}

class _DatabaseApp extends State<DatabaseApp> {
  Future<List<Todo>>? todoList;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Example')),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const CircularProgressIndicator();
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                case ConnectionState.active:
                  return const CircularProgressIndicator();
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        Todo todo = (snapshot.data as List<Todo>)[index];
                        return Card(child: Column(
                          children: <Widget>[
                            Text(todo.title!),
                            Text(todo.content!),
                            Text(todo.active.toString()),
                          ],
                        ),
                        );
                      },
                    );
                  } else {
                    return const Text('데이터없음');
                  }
              }
              return const CircularProgressIndicator();
            },
            future: todoList,
          ),
        ),
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final todo = await Navigator.of(context).pushNamed('/add');
          if (todo != null) {
            _insertTodo(todo as Todo);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

    @override
    void initState() {
      super.initState();
      todoList = getTodos();
    }
    

  Future<List<Todo>> getTodos() async {
      final Database database = await widget.db;
      final List<Map<String, dynamic>> maps = await database.query('todos');

      return List.generate(maps.length, (i) {
        bool active = maps[i]['acitve'] == 1 ? true: false;
        return Todo(
          title: maps[i]['title'].toString(),
          content: maps[i]['content'].toString(),
          active: active,
          id: maps[i]['id']
        );
      });
  }

  void _insertTodo(Todo todo) async {
    final Database database = await widget.db; //widget을 이용하면 현재 State 상위에 있는 StatefulWidget에 있는 변수 사용가능.
    await database.insert('todos', todo.toMap(), conflictAlgorithm : ConflictAlgorithm.replace); //테이블명, 데이터, 충돌이발생할 경우 대비(충돌 발생하면 새 데이터로 교체하고자)

  }
}
