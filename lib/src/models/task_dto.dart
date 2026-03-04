import 'package:isar_community/isar.dart';
part 'task_dto.g.dart';
@collection
class TaskDto {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uuid;
  late String title;
  late String description;
  late bool isCompleted;
  DateTime? deadline;
  int? estimatedDurationMinutes;
  int actualDurationMinutes = 0;
  String? dependencyTaskId;
  DateTime? createdAt;
  DateTime? updatedAt;
}
