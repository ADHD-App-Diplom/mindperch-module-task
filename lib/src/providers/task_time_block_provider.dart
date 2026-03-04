import 'package:mindperch_core/mindperch_core.dart';
import '../repositories/task_repository.dart';

class TaskTimeBlockProvider implements TimeBlockProvider {
  final TaskRepository _repository;

  TaskTimeBlockProvider(this._repository);

  @override
  Stream<List<TimeBlock>> getTimeBlocksStream() {
    return _repository.watchAll().map((tasks) => tasks.cast<TimeBlock>());
  }

  @override
  Future<List<TimeBlock>> getTimeBlocks() async {
    final tasks = await _repository.getAll();
    return tasks.cast<TimeBlock>();
  }
}
