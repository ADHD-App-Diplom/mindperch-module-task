# Task Module (`mindperch-module-task`)

## High-Level Overview
The **Task Module** provides a low-friction, high-reward system for managing one-off actions. It is optimized for ADHD "Brain Dumps" and uses sequential logic to prevent decision fatigue.

## Key Features
- **Brain-Dump**: A specialized input field that allows users to quickly capture multiple tasks at once.
- **Focus Mode**: A full-screen view that isolates a single task, removing all other visual noise.
- **Dopamine-Check**: Satisfying visual rewards upon task completion.
- **Sequential Logic**: Tasks can depend on one another, hiding complex steps until the prerequisite is finished.

## Technical Details
- **Persistence**: Uses `IsarTaskRepository` built on top of `mindperch-isar`.
- **Interface**: Implements the `TimeBlock` domain interface for integration with the MindDial.
