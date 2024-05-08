import 'package:hive_flutter/adapters.dart';
part 'data.g.dart';
// مرسییی پسرر دمت گرمم
// khahesh mikonam

@HiveType(typeId: 0)
class TaskEntity extends HiveObject {
  @HiveField(0)
  String name = '';
  @HiveField(1)
  bool isCompleted = false;
  @HiveField(2)
  Priority priority = Priority.low;
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high
}
