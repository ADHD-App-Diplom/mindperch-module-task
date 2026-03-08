import 'src/providers/task_search_provider.dart';
import 'src/providers/task_time_block_provider.dart';
import 'src/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:mindperch_core/mindperch_core.dart';
import 'package:mindperch_module_api/mindperch_module_api.dart';
import 'package:mindperch_ui_api/mindperch_ui_api.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'src/models/task_dto.dart';
import 'src/repositories/isar_task_repository.dart';
import 'src/ui/task_view.dart';

class TaskModuleInstaller implements ModuleInstaller {
  const TaskModuleInstaller();

  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'mindperch-task',
    displayNameKey: 'tasksTitle',
    descriptionKey: 'tasksDescription',
    displayName: 'Tasks',
    description: 'Low-friction ADHD task capture',
    iconData: Icons.task_alt,
  );

  @override
  List<dynamic> get isarSchemas => [TaskDtoSchema];

  @override
  Future<List<SingleChildWidget>> install(
    DatabaseRegistry databases, {
    SyncRegistry? syncRegistry,
    TimeBlockRegistry? timeBlockRegistry,
    SearchRegistry? searchRegistry,
  }) async {
    final database = databases.require<Isar>();
    final repo = IsarTaskRepository(database);

    if (timeBlockRegistry != null) {
      timeBlockRegistry.registerProvider(TaskTimeBlockProvider(repo));
    }
    if (searchRegistry != null) {
      searchRegistry.registerProvider(TaskSearchProvider(repo));
    }

    return [Provider<TaskRepository>.value(value: repo)];
  }

  @override
  void registerUI(BuildContext context) {
    final layoutService = context.read<AbstractLayoutService>();
    layoutService.registerModuleView(
      'mindperch-task',
      'default',
      (context) => const TaskView(),
    );
  }
}
