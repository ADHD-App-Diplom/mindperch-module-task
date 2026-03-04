import '../models/task_item.dart';
import '../repositories/task_repository.dart';
import '../repositories/task_repository.dart';
import '../models/task_item.dart';
import 'package:flutter/material.dart';
import 'package:mindperch_ui_api/mindperch_ui_api.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:mindperch_core/mindperch_core.dart';
import 'package:mindperch_module_api/mindperch_module_api.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final TextEditingController _dumpController = TextEditingController();
  late ConfettiController _confettiController;
  bool _focusMode = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _dumpController.dispose();
    super.dispose();
  }

  void _onAddTask(String input) {
    if (input.trim().isEmpty) return;
    final repo = context.read<TaskRepository>();
    final lines = input.split('\n');
    for (var line in lines) {
      final title = line.trim();
      if (title.isNotEmpty) repo.save(TaskItem.create(title: title));
    }
    _dumpController.clear();
  }

  void _handleCompletion(
    TaskItem task,
    bool isCompleted, {
    RewardLevel level = RewardLevel.bronze,
  }) {
    final repo = context.read<TaskRepository>();
    repo.save(task.copyWith(isCompleted: isCompleted));
    if (isCompleted) {
      _confettiController.play();
      try {
        context.read<AbstractStreakService>().recordCompletion(
          points: 10,
          level: level,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TaskRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHD Tasks'),
        actions: [
          IconButton(
            icon: Icon(
              _focusMode ? Icons.view_list : Icons.center_focus_strong,
            ),
            onPressed: () => setState(() => _focusMode = !_focusMode),
            tooltip: _focusMode ? 'List View' : 'Focus Mode',
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<TaskItem>>(
            stream: repo.watchAll(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              final activeTasks = tasks.where((t) => !t.isCompleted).toList();

              if (_focusMode && activeTasks.isNotEmpty) {
                return _FocusTaskView(
                  task: activeTasks.first,
                  onComplete: () => _handleCompletion(
                    activeTasks.first,
                    true,
                    level: RewardLevel.gold,
                  ),
                );
              }

              // Organize by hierarchy
              final List<TaskItem> orderedTasks = [];
              final rootTasks = activeTasks
                  .where((t) => t.parentTaskId == null)
                  .toList();
              for (final root in rootTasks) {
                orderedTasks.add(root);
                orderedTasks.addAll(
                  activeTasks.where((t) => t.parentTaskId == root.id),
                );
              }

              return Column(
                children: [
                  _MoodSyncSuggestion(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _dumpController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Brain-Dump: One task per line...',
                        prefixIcon: const Icon(Icons.psychology),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _onAddTask(_dumpController.text),
                        ),
                      ),
                      // Allow natural multiline, but trigger via button or a physical keyboard shortcut could be added here
                    ),
                  ),
                  Expanded(
                    child: orderedTasks.isEmpty
                        ? const Center(
                            child: Text('Clear mind, clear tasks! 🌟'),
                          )
                        : ListView.builder(
                            itemCount: orderedTasks.length,
                            itemBuilder: (context, index) {
                              final task = orderedTasks[index];
                              final isSubTask = task.parentTaskId != null;
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: isSubTask ? 32.0 : 0.0,
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (val) => _handleCompletion(
                                      task,
                                      val ?? false,
                                      level:
                                          task.estimatedDurationMinutes != null
                                          ? RewardLevel.silver
                                          : RewardLevel.bronze,
                                    ),
                                  ),
                                  title: Text(task.title),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => repo.delete(task.id),
                                  ),
                                  onLongPress: () =>
                                      _showTaskOptions(context, task),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(BuildContext context, TaskItem task) {
    if (task.parentTaskId != null) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Add Sub-task'),
            onTap: () {
              Navigator.pop(ctx);
              _showAddSubtaskDialog(task);
            },
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog(TaskItem parent) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sub-task for ${parent.title}'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                final repo = context.read<TaskRepository>();
                repo.save(
                  TaskItem.create(
                    title: ctrl.text.trim(),
                    parentTaskId: parent.id,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _MoodSyncSuggestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      final cycleService = context.watch<AbstractCycleService>();
      return StreamBuilder<CyclePrediction?>(
        stream: cycleService.watchCurrentState(),
        builder: (context, snapshot) {
          final prediction = snapshot.data;
          if (prediction != null && prediction.phase == CyclePhase.luteal) {
            return Container(
              width: double.infinity,
              color: Colors.pink.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mood-Sync: You are in the Luteal phase. We suggest starting with low-friction tasks today.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _FocusTaskView extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onComplete;
  const _FocusTaskView({required this.task, required this.onComplete});

  @override
  State<_FocusTaskView> createState() => _FocusTaskViewState();
}

class _FocusTaskViewState extends State<_FocusTaskView>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(minutes: widget.task.estimatedDurationMinutes ?? 25),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'CURRENT FOCUS',
            style: TextStyle(color: Colors.grey, letterSpacing: 2),
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 12,
                      color: Colors.orangeAccent,
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(250, 70),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            child: const Text(
              'DONE!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
