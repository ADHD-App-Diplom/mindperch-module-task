import '../models/task_item.dart';
import 'task_repository.dart';
import 'package:mindperch_isar/mindperch_isar.dart';
import '../models/task_dto.dart';
class IsarTaskRepository extends IsarStorage<TaskItem, TaskDto> implements TaskRepository {
  IsarTaskRepository(super.isar);
  @override IsarCollection<TaskDto> get collection => isar.taskDtos;
  @override TaskItem mapToDomain(TaskDto dto) => TaskItem(
      id: dto.uuid, title: dto.title, description: dto.description,
      isCompleted: dto.isCompleted, deadline: dto.deadline,
      estimatedDurationMinutes: dto.estimatedDurationMinutes,
      actualDurationMinutes: dto.actualDurationMinutes,
      dependencyTaskId: dto.dependencyTaskId,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
  );
  @override TaskDto mapToDto(TaskItem entity) => TaskDto()
      ..uuid = entity.id ..title = entity.title ..description = entity.description
      ..isCompleted = entity.isCompleted ..deadline = entity.deadline
      ..estimatedDurationMinutes = entity.estimatedDurationMinutes
      ..actualDurationMinutes = entity.actualDurationMinutes
      ..dependencyTaskId = entity.dependencyTaskId
      ..createdAt = entity.createdAt ..updatedAt = entity.updatedAt;
  @override Future<TaskDto?> findByUuid(String uuid) => isar.taskDtos.filter().uuidEqualTo(uuid).findFirst();
  @override Future<void> performDelete(TaskDto dto) => isar.taskDtos.delete(dto.id);
  @override Future<TaskItem?> getById(String id) => getByUuid(id);
  @override Stream<List<TaskItem>> watchIncomplete() => collection.filter().isCompletedEqualTo(false).watch().map((dtos) => dtos.map(mapToDomain).toList());
  @override Future<List<TaskItem>> getAll() async { final dtos = await collection.where().findAll(); return dtos.map(mapToDomain).toList(); }
}
