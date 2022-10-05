import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/data.dart';
import 'package:to_do_list/main.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskEtity task;

    const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.task.name);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Edit Task'),
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.task.name = _controller.text;
          widget.task.priority = widget.task.priority;
          if (widget.task.isInBox) {
            widget.task.save();
          } else {
            final Box<TaskEtity> box = Hive.box(taskBoxName);
            box.add(widget.task);
          }
          Navigator.of(context).pop();
        },
        label: const Text('save changes'),
        icon: const Icon(CupertinoIcons.check_mark_circled),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 1,
                  child: PriorityCard(
                    label: 'High',
                    color: highPriority,
                    isSelected: widget.task.priority == Priority.high,
                    callback: () {
                      setState(() {
                        widget.task.priority = Priority.high;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  flex: 1,
                  child: PriorityCard(
                      label: 'Normal',
                      color: normalPriority,
                      isSelected: widget.task.priority == Priority.normal,
                      callback: () {
                        setState(() {
                          widget.task.priority = Priority.normal;
                        });
                      }),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  flex: 1,
                  child: PriorityCard(
                      label: 'Low',
                      color: lowPriority,
                      isSelected: widget.task.priority == Priority.low,
                      callback: () {
                        setState(() {
                          widget.task.priority = Priority.low;
                        });
                      }),
                ),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  label: Text(
                'Add a task for today...',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .apply(fontSizeFactor: 1.4),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class PriorityCard extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureDoubleTapCallback callback;

  const PriorityCard(
      {Key? key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: callback,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(width: 2, color: secondaryTextColor.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(label),
            ),
            Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                    child: PriorityCheckBox(
                  value: isSelected,
                  color: color,
                ))),
          ],
        ),
      ),
    );
  }
}
