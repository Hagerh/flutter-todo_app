import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'To-DO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<TodoGroup> _taskGroups = [
    TodoGroup(
      title: "Study Flutter course",
      tasks: [
        Todo(title: "Review lecture slides", isDone: true),
        Todo(title: "Solve examples", isDone: true),
        Todo(title: "Review assignments", isDone: false),
      ],
    ),
    TodoGroup(
      title: "Game Development  ",
      tasks: [
        Todo(title: "Project", isDone: true),
        Todo(title: "Quiz", isDone: true),
        Todo(title: "Assignment", isDone: false),
        Todo(title: "Finals", isDone: false),
      ],
    ),
    TodoGroup(
      title: "Mathmatics 2",
      tasks: [
        Todo(title: "Review lecture slides", isDone: true),
        Todo(title: "Solve examples", isDone: true),
        Todo(title: "Review assignments", isDone: false),
      ],
    ),
  ];

//Two-level indexing
  void _toggleTask(int groupIndex, int taskIndex) {
    setState(() {
      _taskGroups[groupIndex].tasks[taskIndex].isDone =
      !_taskGroups[groupIndex].tasks[taskIndex].isDone;
    });
  }

  void _deleteTaskGroup(int groupIndex) {
    setState(() {
      _taskGroups.removeAt(groupIndex);
    });
  }

  void _addNewTodoGroup(String groupTitle, List<String> taskTitles){
    setState(() {
      List<Todo> newTasks = taskTitles
          .where((title) => title.trim().isNotEmpty)
          .map((title) => Todo(title: title.trim()))
          .toList();

      if (newTasks.isNotEmpty) {
        _taskGroups.add(TodoGroup(title: groupTitle, tasks: newTasks));
      }
    });
  }

  void _showAddTodoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoBottomSheet(onAddTodo: _addNewTodoGroup,),
    );
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = MediaQuery.of(context).size.width > 800;

    int pendingCount = 0;
    int completeCount = 0;

    for (var group in _taskGroups) {
      for (var task in group.tasks) {
        if (task.isDone) {
          completeCount++;
        } else {
          pendingCount++;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.access_alarm_rounded,
              color: Colors.lightBlue,
              size: 30,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isDesktop ? DesktopLayout(
        title: widget.title,
        pendingCount: pendingCount,
        completeCount: completeCount,
        taskGroups: _taskGroups,
        toggleTask: _toggleTask,
        deleteTaskGroup: _deleteTaskGroup,
        onShowAddTodo: _showAddTodoBottomSheet,
      )
          : MobileLayout(
        pendingCount: pendingCount,
        completeCount: completeCount,
        taskGroups: _taskGroups,
        toggleTask: _toggleTask,
        deleteTaskGroup: _deleteTaskGroup,
      ),
      floatingActionButton: isDesktop ? null : FloatingActionButton(
        onPressed: _showAddTodoBottomSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

//  Desktop Layout
class DesktopLayout extends StatelessWidget {
  final String title;
  final int pendingCount;
  final int completeCount;
  final List<TodoGroup> taskGroups;
  final Function(int, int) toggleTask;
  final Function(int) deleteTaskGroup;
  final VoidCallback onShowAddTodo;

  const DesktopLayout({
    super.key,
    required this.title,
    required this.pendingCount,
    required this.completeCount,
    required this.taskGroups,
    required this.toggleTask,
    required this.deleteTaskGroup,
    required this.onShowAddTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Sidebar
        DesktopSidebar(
          title: title,
          pendingCount: pendingCount,
          completeCount: completeCount,
        ),

        Expanded(
          child: DesktopMainContent(
            taskGroups: taskGroups,
            toggleTask: toggleTask,
            deleteTaskGroup: deleteTaskGroup,
            onShowAddTodo: onShowAddTodo,
          ),
        ),
      ],
    );
  }
}

//  Desktop Sidebar
class DesktopSidebar extends StatelessWidget {
  final String title;
  final int pendingCount;
  final int completeCount;

  const DesktopSidebar({
    super.key,
    required this.title,
    required this.pendingCount,
    required this.completeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_alarm_rounded,
                color: Colors.lightBlue,
                size: 30,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blue,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),


          const PersonalInformation(),

          const SizedBox(height: 20),


          TaskStatusView(
            pendingCount: pendingCount,
            completeCount: completeCount,
          ),

          const SizedBox(height: 30),

          DesktopProgressCharts(
            pendingCount: pendingCount,
            completeCount: completeCount,
          ),
        ],
      ),
    );
  }
}


class DesktopProgressCharts extends StatelessWidget {
  final int pendingCount;
  final int completeCount;

  const DesktopProgressCharts({
    super.key,
    required this.pendingCount,
    required this.completeCount,
  });

  @override
  Widget build(BuildContext context) {
    int totalTasks = pendingCount + completeCount;
    double donePercentage = totalTasks > 0 ? completeCount / totalTasks : 0;


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Done Tasks Chart
        Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: donePercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${(donePercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To-Dos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Done'),
                const SizedBox(width: 8),
                Text('Pending'),
              ],
            ),
          ],
        ),
        // Tasks Chart
        Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: donePercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${(donePercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tasks',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Done'),
                const SizedBox(width: 8),
                Text('Pending'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

//  Desktop Main Content
class DesktopMainContent extends StatelessWidget {
  final List<TodoGroup> taskGroups;
  final Function(int, int) toggleTask;
  final Function(int) deleteTaskGroup;
  final VoidCallback onShowAddTodo;

  const DesktopMainContent({
    super.key,
    required this.taskGroups,
    required this.toggleTask,
    required this.deleteTaskGroup,
    required this.onShowAddTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My To-Dos",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
              ),
              ElevatedButton.icon(
                onPressed: onShowAddTodo,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add To-Do',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),


          Expanded(
            child: DesktopTodosGrid(
              taskGroups: taskGroups,
              toggleTask: toggleTask,
              deleteTaskGroup: deleteTaskGroup,
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopTodosGrid extends StatelessWidget {
  final List<TodoGroup> taskGroups;
  final Function(int, int) toggleTask;
  final Function(int) deleteTaskGroup;

  const DesktopTodosGrid({
    super.key,
    required this.taskGroups,
    required this.toggleTask,
    required this.deleteTaskGroup,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16, //gap between columns
        mainAxisSpacing: 16, //gap between rows.
        childAspectRatio: 1.2,
      ),
      itemCount: taskGroups.length,
      itemBuilder: (context, groupIndex) {
        final todoGroup = taskGroups[groupIndex];
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todoGroup.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${todoGroup.totalCount} Tasks",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => deleteTaskGroup(groupIndex),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: todoGroup.tasks.length,
                  itemBuilder: (context, taskIndex) {
                    final task = todoGroup.tasks[taskIndex];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true, // Make more compact for grid
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        leading: Icon(
                          task.isDone
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task.isDone ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone
                                ? Colors.green
                                : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => toggleTask(groupIndex, taskIndex),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

//  Mobile Layout
class MobileLayout extends StatelessWidget {
  final int pendingCount;
  final int completeCount;
  final List<TodoGroup> taskGroups;
  final Function(int, int) toggleTask;
  final Function(int) deleteTaskGroup;

  const MobileLayout({
    super.key,
    required this.pendingCount,
    required this.completeCount,
    required this.taskGroups,
    required this.toggleTask,
    required this.deleteTaskGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonalInformation(),
          const SizedBox(height: 20),
          TaskStatusView(
            pendingCount: pendingCount,
            completeCount: completeCount,
          ),
          const SizedBox(height: 12),
          const Text(
            "My To-Dos",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
          ToDos(
            taskGroups: taskGroups,
            toggleTask: toggleTask,
            deleteTaskGroup: deleteTaskGroup,
          ),
        ],
      ),
    );
  }
}

class PersonalInformation extends StatelessWidget {
  const PersonalInformation({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    const String username = "Hager";
    const String profileImageUrl = "https://via.placeholder.com/150";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE: Avatar + Greeting
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(profileImageUrl),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "${_getGreeting()}, ",
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                            const TextSpan(
                              text: username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        overflow: TextOverflow.ellipsis,
                        "Have a wonderful day!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // RIGHT SIDE: Notification Icon
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
              color: Colors.blue,
            ),
            onPressed: () {
              // TODO: handle notification tap
            },
          ),
        ],
      ),
    );
  }
}

class TaskStatusView extends StatelessWidget {
  final int pendingCount;
  final int completeCount;
  const TaskStatusView({
    super.key,
    required this.pendingCount,
    required this.completeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pending", style: TextStyle(color: Colors.white)),
                  Text(
                    "$pendingCount Tasks",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const Icon(Icons.access_time, color: Colors.white),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Done", style: TextStyle(color: Colors.white)),
                  Text(
                    "$completeCount Tasks",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        )
      ],
    );
  }
}

class Todo {
  final String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});
}

class TodoGroup {
  final String title;
  final List<Todo> tasks;

  TodoGroup({required this.title, required this.tasks});

  int get completedCount => tasks.where((task) => task.isDone).length;
  int get totalCount => tasks.length;
}

class ToDos extends StatelessWidget {
  final List<TodoGroup> taskGroups;
  final Function(int, int) toggleTask;
  final Function(int) deleteTaskGroup;

  const ToDos({
    super.key,
    required this.taskGroups,
    required this.toggleTask,
    required this.deleteTaskGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder( //lazy loading
        itemCount: taskGroups.length,  //create as many list items as there are TodoGroups
        itemBuilder: (context, groupIndex) {  //for each item that needs to be displayed
          final todoGroup = taskGroups[groupIndex];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoGroup.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${todoGroup.totalCount} Tasks",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => deleteTaskGroup(groupIndex),
                      ),
                    ],
                  ),
                ),

                // Tasks List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todoGroup.tasks.length,
                  itemBuilder: (context, taskIndex) {
                    final task = todoGroup.tasks[taskIndex];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Icon(
                          task.isDone
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task.isDone ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                        onTap: () => toggleTask(groupIndex, taskIndex),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddTodoBottomSheet extends StatefulWidget {
  final Function(String, List<String>) onAddTodo;

  const AddTodoBottomSheet({super.key, required this.onAddTodo});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {

  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _taskControllers = [TextEditingController()];

  void _addTaskField() {
    setState(() {
      _taskControllers.add(TextEditingController());
    });
  }

  void _removeTaskField(int index) {
    if (_taskControllers.length > 1) { //at least 1 task feild exists
      setState(() {
        _taskControllers[index].dispose();  //  Prevent memory leak
        _taskControllers.removeAt(index);
      });
    }
  }

  void _saveTodo() {
    // Validate group name
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Major Task name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<String> taskTitles = _taskControllers.map((controller) => controller.text)   // Get text from each controller
        .where((text) => text.trim().isNotEmpty) //leave the empty ones
        .toList(); //convert to list

    if (taskTitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one task'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

//save data in the parent widget
    widget.onAddTodo(_titleController.text.trim(), taskTitles);
    Navigator.pop(context); //close sheet
  }

  @override  //MUST with controllers
  void dispose() {
    _titleController.dispose();
    for (var controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            const Text(
              'Add New Todo Group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
              IconButton(
                onPressed: () => Navigator.pop(context), //open sheet
                icon: const Icon(Icons.close),
              ),
            ],
            ),
              const SizedBox(height: 20),

              // Todos Group Name Input
              const Text(
                'Major Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter Major Task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addTaskField,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Input Fields
              ConstrainedBox(  //Prevents the task list from taking up infinite height and makes it scrollable when it gets too tall
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      _taskControllers.length, // How many items to create
                          (index) => Padding( //creates each item
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Task ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            if (_taskControllers.length > 1) //at least one task
                              IconButton(
                                onPressed: () => _removeTaskField(index),
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Major Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
        ),
    );
  }
}
