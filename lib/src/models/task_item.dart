import 'package:mindperch_core/mindperch_core.dart';

class TaskItem extends BaseEntity implements TimeBlock {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? deadline;
  final int? estimatedDurationMinutes;
  final int actualDurationMinutes;
  final String? dependencyTaskId;
  final String? parentTaskId; // For hierarchy

  @override
  String get blockType => 'task';

  @override
  TimeRange? get timeRange => deadline != null 
    ? TimeRange(start: deadline!, end: deadline!.add(Duration(minutes: estimatedDurationMinutes ?? 30)))
    : null;

  @override
  int get frictionScore => 5;

  @override
  String get mentalLoad => 'medium';

  @override
  int? get estimatedDuration => estimatedDurationMinutes;

  @override
  int? get actualDuration => actualDurationMinutes;

  @override
  String get categoryKey => 'task';

  TaskItem({
    required super.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.deadline,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes = 0,
    this.dependencyTaskId,
    this.parentTaskId,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory TaskItem.create({
    required String title,
    String description = '',
    DateTime? deadline,
    int? estimatedDurationMinutes,
    String? dependencyTaskId,
    String? parentTaskId,
  }) {
    final now = DateTime.now().toUtc();
    return TaskItem(
      id: generateId(),
      title: title,
      description: description,
      deadline: deadline,
      estimatedDurationMinutes: estimatedDurationMinutes,
      dependencyTaskId: dependencyTaskId,
      parentTaskId: parentTaskId,
      createdAt: now,
      updatedAt: now,
    );
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? deadline,
    int? estimatedDurationMinutes,
    int? actualDurationMinutes,
    String? dependencyTaskId,
    String? parentTaskId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      dependencyTaskId: dependencyTaskId ?? this.dependencyTaskId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, title, isCompleted, parentTaskId];
}
