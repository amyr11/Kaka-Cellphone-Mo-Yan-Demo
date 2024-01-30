import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Todo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Todo {
  String title;
  bool isCompleted;
  int? index;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.index,
  });
}

List<Todo> todos = [];

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  void _onCleanButtonPressed() {
    setState(() {
      todos.removeWhere((todo) => todo.isCompleted);
    });
  }

  void _reindexTodos() {
    List<Todo> completedTodos =
        todos.where((todo) => todo.isCompleted).toList();
    List<Todo> uncompletedTodos =
        todos.where((todo) => !todo.isCompleted).toList();

    // sort completed todos
    completedTodos.sort((a, b) => a.index!.compareTo(b.index!));

    // sort uncompleted todos
    uncompletedTodos.sort((a, b) => a.index!.compareTo(b.index!));

    // merge todos
    todos = [...uncompletedTodos, ...completedTodos];
  }

  void _onItemStatusChanged(Todo todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
      _reindexTodos();
    });
  }

  void _onItemDeleted(Todo todo) {
    setState(() {
      todos.remove(todo);
    });
  }

  void _onAddButtonPressed() {
    if (_controller.text.isEmpty) {
      return;
    }

    setState(() {
      _addTodo(
        _controller.text,
      );
      _clearInput();
    });
  }

  void _addTodo(String title) {
    setState(() {
      todos.add(Todo(
        title: title,
        index: todos.length,
      ));
    });
  }

  void _clearInput() {
    setState(() {
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "My Todo's",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "${todos.where((todo) => todo.isCompleted).length}/${todos.length}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _onCleanButtonPressed();
                    },
                    child: const Text("Clean"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: todos.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Center(
                          child: Text(
                            "Yey! No todo's.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        shrinkWrap: true,
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return TodoItem(
                            todo: todos[index],
                            onStatusChanged: _onItemStatusChanged,
                            onDeleted: _onItemDeleted,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  _onAddButtonPressed();
                },
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Add a new todo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _onAddButtonPressed();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  final Function onDeleted;
  final Function onStatusChanged;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onDeleted,
    required this.onStatusChanged,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      contentPadding: EdgeInsets.zero,
      title: Text(
        widget.todo.title,
        style: TextStyle(
          decoration: widget.todo.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      leading: Checkbox(
        value: widget.todo.isCompleted,
        onChanged: (value) {
          widget.onStatusChanged(widget.todo);
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          widget.onDeleted(widget.todo);
        },
      ),
    );
  }
}
