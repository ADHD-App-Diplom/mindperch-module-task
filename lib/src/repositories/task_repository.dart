import '../models/task_item.dart';
import 'package:mindperch_core/mindperch_core.dart';

abstract class TaskRepository {
  Future<void> save(TaskItem task);
  Future<void> delete(String id);
  Future<TaskItem?> getById(String id);
  Future<List<TaskItem>> getAll();
  Stream<List<TaskItem>> watchAll();
  Stream<List<TaskItem>> watchIncomplete();
}
