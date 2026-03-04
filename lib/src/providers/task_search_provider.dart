import 'package:mindperch_core/mindperch_core.dart';
import '../repositories/task_repository.dart';

class TaskSearchProvider implements SearchProvider {
  final TaskRepository _repository;

  TaskSearchProvider(this._repository);

  @override
  String get moduleType => 'mindperch-task';

  @override
  Future<List<SearchResult>> search(String query) async {
    final tasks = await _repository.getAll();
    return tasks
        .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
        .map(
          (t) => SearchResult(
            id: t.id,
            title: t.title,
            subtitle: t.description,
            moduleType: moduleType,
            payload: t,
          ),
        )
        .toList();
  }
}
