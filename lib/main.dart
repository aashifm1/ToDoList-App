import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo,
                ),
              ),
            )
          : ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo,
                ),
              ),
            ),
      home: TodoListPage(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime? dueDate;

  Task(this.title, {this.isCompleted = false, this.dueDate});
}

class TodoListPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TodoListPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (selectedDate != null) {
        setState(() {
          _tasks.add(Task(text, dueDate: selectedDate));
          _controller.clear();
        });
      }
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final TextEditingController editController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Update task'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                setState(() {
                  _tasks[index].title = updatedText;
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 2,
        title: const Text('📝 My To-Do List'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[900]!, Colors.black]
                : [const Color(0xFFece9e6), const Color(0xFFffffff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.task),
                          hintText: 'Enter a new task...',
                          filled: true,
                          fillColor: isDark ? Colors.grey[850] : Colors.white,
                          hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Task Stats
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text(
                        "Total: ${_tasks.length}",
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.indigo[900],
                        ),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.indigo[100],
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(
                        "Completed: ${_tasks.where((t) => t.isCompleted).length}",
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.green[900],
                        ),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.green[100],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Task List
              Expanded(
                child: _tasks.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 80, color: Colors.grey[500]),
                          const SizedBox(height: 10),
                          Text(
                            'No tasks yet!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Dismissible(
                            key: Key(task.title + index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              setState(() {
                                _tasks.removeAt(index);
                              });
                            },
                            child: Card(
                              color: isDark ? Colors.grey[850] : Colors.white,
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTaskCompletion(index),
                                  activeColor: Colors.indigo,
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : (isDark ? Colors.white : Colors.black),
                                  ),
                                ),
                                subtitle: task.dueDate != null
                                    ? Text(
                                        'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                        ),
                                      )
                                    : null,
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editTask(index),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
