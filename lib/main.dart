import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/edit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';

const taskBoxName = 'tasks';
void main() async {
  // initialazing hive
  await Hive.initFlutter();
  // register my class for hive
  Hive.registerAdapter<TaskEntity>(TaskEntityAdapter());
  Hive.registerAdapter<Priority>(PriorityAdapter());
  // type = Future<Box<dynamic>>
  await Hive.openBox<TaskEntity>(taskBoxName);
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryVariantColor = Color(0xff5C0AFF);
const Color secondaryTextColor = Color(0xffAFBED0);
const Color primaryTextColor = Color(0xff1D2830);
const Color highPrirityColor = primaryColor;
const Color normalPrirityColor = Colors.orange;
const Color lowPrirityColor = Colors.blue;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
            primary: primaryColor,
            primaryContainer: primaryVariantColor,
            background: Color(0xffF3F5F8),
            onSurface: primaryTextColor,
            onPrimary: Colors.white,
            onBackground: Color.fromARGB(255, 240, 240, 240),
            secondary: primaryColor,
            onSecondary: Colors.white),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          prefixIconColor: secondaryTextColor,
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _notifier = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Box<TaskEntity> box = Hive.box(taskBoxName);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditingTaskBarScreen(
                      task: TaskEntity(),
                    )));
          },
          label: const Text('Add Task')),
      // for fixed app bar and body
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 102,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.primaryContainer,
                  ])),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To Do List',
                          style: themeData.textTheme.titleLarge,
                        ),
                        Icon(
                          Icons.ios_share,
                          color: themeData.colorScheme.onPrimary,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5)
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          _notifier.value = value;
                        },
                        controller: _searchController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                            ),
                            label: Text(
                              'Search tasks...',
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _notifier,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return ValueListenableBuilder<Box<TaskEntity>>(
                      valueListenable: box.listenable(),
                      builder:
                          (BuildContext context, Box<TaskEntity> boxes, child) {
                        final Iterable items;
                        if (_searchController.text.isEmpty) {
                          items = boxes.values;
                        } else {
                          items = boxes.values.where((element) =>
                              element.name.contains(_searchController.text));
                        }
                        if (items.isNotEmpty) {
                          return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {},
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Today',
                                                style: themeData
                                                    .textTheme.titleMedium),
                                            Container(
                                              width: 70,
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                  color: themeData
                                                      .colorScheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            )
                                          ],
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: MaterialButton(
                                          color: const Color.fromARGB(
                                              219, 59, 59, 61),
                                          onPressed: () {
                                            for (int i = items.length - 1;
                                                i >= 0;
                                                i--) {
                                              final TaskEntity task =
                                                  items.toList()[i];
                                              if (task.isCompleted) {
                                                task.delete();
                                              }
                                            }
                                          },
                                          elevation: 0,
                                          child: Row(
                                            children: [
                                              Text(
                                                'Delete',
                                                style: themeData
                                                    .textTheme.titleMedium,
                                              ),
                                              const Icon(
                                                CupertinoIcons.delete,
                                                size: 15.1,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: MaterialButton(
                                          color: const Color.fromARGB(
                                              219, 59, 59, 61),
                                          onPressed: () {
                                            box.clear();
                                          },
                                          elevation: 0,
                                          child: Row(
                                            children: [
                                              Text(
                                                'Delete All',
                                                style: themeData
                                                    .textTheme.titleMedium,
                                              ),
                                              const Icon(
                                                CupertinoIcons.delete,
                                                size: 15.1,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  final TaskEntity task =
                                      items.toList()[index - 1];
                                  return _TaskItem(
                                      task: task, themeData: themeData);
                                }
                              });
                        } else {
                          return const EmptyStates();
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStates extends StatelessWidget {
  const EmptyStates({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('your tasks is empty'),
          const SizedBox(
            height: 20,
          ),
          SvgPicture.asset(
            width: 200,
            'assets/empty_state.svg',
          )
        ],
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 / 2),
        border:
            value ? null : Border.all(color: secondaryTextColor, width: 2.51),
        color: value ? primaryColor : null,
      ),
      child: value
          ? Icon(
              size: 12,
              CupertinoIcons.check_mark,
              color: themeData.colorScheme.onPrimary,
            )
          : null,
    );
  }
}

class _TaskItem extends StatefulWidget {
  const _TaskItem({
    required this.task,
    required this.themeData,
  });

  final TaskEntity task;
  final ThemeData themeData;
  static const double borderRadius = 5;

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> {
  @override
  Widget build(BuildContext context) {
    final Color priorityColor;
    final Color pencilIconColor;
    switch (widget.task.priority) {
      case Priority.high:
        priorityColor = highPrirityColor;
        pencilIconColor = Colors.red;
        break;

      case Priority.normal:
        priorityColor = normalPrirityColor;
        pencilIconColor = Colors.black;
        break;

      case Priority.low:
        priorityColor = lowPrirityColor;
        pencilIconColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          setState(() {
            widget.task.isCompleted = !widget.task.isCompleted;
          });
        },
        child: Container(
          width: double.infinity,
          height: 84,
          decoration: BoxDecoration(
              color: widget.themeData.colorScheme.onBackground,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
              ],
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              const SizedBox(width: 8),
              MyCheckBox(value: widget.task.isCompleted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.task.name,
                  style: widget.themeData.textTheme.titleMedium!.apply(
                      fontSizeFactor: 0.8,
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            EditingTaskBarScreen(task: widget.task)));
                  },
                  icon: Icon(CupertinoIcons.pencil, color: pencilIconColor)),
              const SizedBox(width: 12),
              Container(
                width: 6,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(_TaskItem.borderRadius),
                        bottomRight: Radius.circular(_TaskItem.borderRadius))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
