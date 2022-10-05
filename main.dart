import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/data.dart';
import 'package:to_do_list/edit.dart';

const taskBoxName = 'tasks';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEtity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryVariantColor));
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryVariantColor = Color(0xff5C0AFF);
const Color secondaryTextColor = Color(0xffAFBED0);
const Color normalPriority = Color(0xffF09819);
const Color lowPriority = Color(0xff3BE1F1);
const Color highPriority = primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1D2830);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.bold),
        )),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          primaryVariant: primaryVariantColor,
          background: Color(0xffF3F5F8),
          onBackground: primaryTextColor,
          onPrimary: Colors.white,
          onSurface: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeyWordNotifier = ValueNotifier(''); 

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEtity>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                      task: TaskEtity(),
                    )));
          },
          label: Row(children: const [
            Icon(CupertinoIcons.plus),
            SizedBox(
              width: 4,
            ),
            Text('Add New Task')
          ])),
      body: SafeArea(
        child: Column(children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
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
                        style: themeData.textTheme.headline6!
                            .apply(color: themeData.colorScheme.onPrimary),
                      ),
                      Icon(
                        CupertinoIcons.share,
                        color: themeData.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ]),
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                       searchKeyWordNotifier.value = controller.text;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.search),
                        label: Text('search tasks...'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: searchKeyWordNotifier,
              builder: (context, value, child) {
                return ValueListenableBuilder<Box<TaskEtity>>(
                valueListenable: box.listenable(),
                builder: ((context, box, child) {
                  final items;
                  if (controller.text.isEmpty) {
                    items = box.values.toList();
                  } else {
                    items = box.values.where((task) => task.name.contains(controller.text)).toList();
                  }
                  if (items.isNotEmpty) {
                    return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('today',
                                          style: themeData.textTheme.headline6!
                                              .apply(fontSizeFactor: 0.9)),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        height: 3,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(1.5)),
                                      )
                                    ]),
                                MaterialButton(
                                  color: const Color(0xffEAEFF5),
                                  textColor: secondaryTextColor,
                                  elevation: 0,
                                  onPressed: () {
                                    box.clear();
                                  },
                                  child: Row(
                                    children: const [
                                      Text('Delet All'),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        CupertinoIcons.delete_solid,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            final TaskEtity task = items[index - 1];
                            return TaskItem(task: task);
                          }
                        });
                  } else {
                    return const EmptyState();
                  }
                }),
              );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'empty.jpg',
          width: 120,
        ),
        const SizedBox(
          height: 12,
        ),
        const Text('Add a Task for Today...'),
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 84;
  static const double borderRadius = 8;
  const TaskItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  final TaskEtity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.high:
        priorityColor = highPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.low:
        priorityColor = lowPriority;
        break;
    }
    return InkWell(
      onTap: (() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task)));
      }),
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        height: TaskItem.height,
        decoration: BoxDecoration(
          color: themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(TaskItem.borderRadius),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          MyCheckBox(
            value: widget.task.isComplited,
            onTap: () {
              setState(() {
                widget.task.isComplited = !widget.task.isComplited;
              });
            },
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Text(
              widget.task.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                decoration:
                    widget.task.isComplited ? TextDecoration.lineThrough : null,
                color: widget.task.isComplited
                    ? themeData.colorScheme.onSurface.withOpacity(0.5)
                    : themeData.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            width: 4,
            height: TaskItem.height,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(TaskItem.borderRadius),
                  bottomRight: Radius.circular(TaskItem.borderRadius)),
            ),
          )
        ]),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;
  final Function() onTap;

  const MyCheckBox({Key? key, required this.value, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: !value
              ? Border.all(
                  color: secondaryTextColor,
                  width: 2,
                )
              : null,
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(CupertinoIcons.check_mark,
                size: 16, color: themeData.colorScheme.onPrimary)
            : null,
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final bool value;
  final Color color;

  const PriorityCheckBox({Key? key, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: value
          ? Icon(CupertinoIcons.check_mark,
              size: 12, color: themeData.colorScheme.onPrimary)
          : null,
    );
  }
}
