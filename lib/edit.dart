import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/main.dart';
import 'package:hive/hive.dart';

class EditingTaskBarScreen extends StatefulWidget {
  const EditingTaskBarScreen({super.key, required this.task});

  final TaskEntity task;

  @override
  State<EditingTaskBarScreen> createState() => _EditingTaskBarScreenState();
}

class _EditingTaskBarScreenState extends State<EditingTaskBarScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.task.name);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            widget.task.name = _controller.text;
            widget.task.priority = widget.task.priority;
            if (widget.task.isInBox) {
              widget.task.save();
            } else {
              final Box<TaskEntity> box = Hive.box(taskBoxName);
              box.add(widget.task);
            }

            Navigator.of(context).pop(context);
          },
          label: const Text('Save')),
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    child: CustomRadioButton(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.high;
                    });
                  },
                  label: 'high',
                  color: highPrirityColor,
                  isActive: widget.task.priority == Priority.high,
                )),
                const SizedBox(width: 12),
                Flexible(
                    child: CustomRadioButton(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.normal;
                    });
                  },
                  label: 'normal',
                  color: normalPrirityColor,
                  isActive: widget.task.priority == Priority.normal,
                )),
                const SizedBox(width: 12),
                Flexible(
                    child: CustomRadioButton(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.low;
                    });
                  },
                  label: 'low',
                  color: lowPrirityColor,
                  isActive: widget.task.priority == Priority.low,
                )),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  label: Text(
                'Add a Task for Today...',
                style: TextStyle(color: primaryTextColor),
              )),
            )
          ],
        ),
      ),
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final GestureTapCallback onTap;
  const CustomRadioButton(
      {super.key,
      required this.label,
      required this.color,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: secondaryTextColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: isActive
                  ? const Center(
                      child: Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                    ))
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
