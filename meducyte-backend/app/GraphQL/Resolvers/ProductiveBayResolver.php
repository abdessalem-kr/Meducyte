<?php

namespace App\GraphQL\Resolvers;

use App\Models\TodoItem;
use App\Models\ExamEvent;
use App\Models\PomodoroSession;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ProductiveBayResolver
{
    public function stats(): array
    {
        $user = Auth::user();
        $today = Carbon::today();
        $startOfWeek = Carbon::now()->startOfWeek();

        $focusMinutesToday = PomodoroSession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereDate('started_at', $today)
            ->sum('duration_minutes');

        $focusMinutesWeek = PomodoroSession::where('user_id', $user->id)
            ->where('status', 'completed')
            ->where('started_at', '>=', $startOfWeek)
            ->sum('duration_minutes');

        $completedTasksToday = TodoItem::where('user_id', $user->id)
            ->where('is_completed', true)
            ->whereDate('updated_at', $today)
            ->count();

        $pomodorosToday = PomodoroSession::where('user_id', $user->id)
            ->where('type', 'work')
            ->where('status', 'completed')
            ->whereDate('started_at', $today)
            ->count();

        // Simple streak calculation (completed pomodoros in consecutive days)
        $currentStreak = 0;
        $checkDate = Carbon::today();
        while (true) {
            $hasActivity = PomodoroSession::where('user_id', $user->id)
                ->where('status', 'completed')
                ->whereDate('started_at', $checkDate)
                ->exists();

            if (!$hasActivity)
                break;
            $currentStreak++;
            $checkDate->subDay();
        }

        return [
            'focus_hours_today' => round($focusMinutesToday / 60, 1),
            'focus_hours_week' => round($focusMinutesWeek / 60, 1),
            'completed_tasks_today' => $completedTasksToday,
            'current_streak' => $currentStreak,
            'pomodoros_completed_today' => $pomodorosToday,
        ];
    }

    public function createTodo($_, array $args): TodoItem
    {
        $todo = TodoItem::create([
            'user_id' => Auth::id(),
            'title' => $args['title'],
            'priority' => $args['priority'] ?? 'optional',
            'deadline' => $args['deadline'] ?? null,
            'module_id' => $args['module_id'] ?? null,
            'estimated_pomodoros' => $args['estimated_pomodoros'] ?? 1,
        ]);

        if (isset($args['subtasks'])) {
            foreach ($args['subtasks'] as $subtaskData) {
                $todo->subtasks()->create([
                    'title' => $subtaskData['title'],
                    'is_completed' => $subtaskData['is_completed'] ?? false,
                ]);
            }
        }

        return $todo->load('subtasks');
    }

    public function updateTodo($_, array $args): TodoItem
    {
        $todo = TodoItem::findOrFail($args['id']);

        if ($todo->user_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $fields = ['title', 'priority', 'deadline', 'is_completed', 'completed_pomodoros', 'estimated_pomodoros', 'module_id'];
        $todo->update(array_intersect_key($args, array_flip($fields)));

        if (isset($args['subtasks'])) {
            $inputSubtaskIds = [];
            foreach ($args['subtasks'] as $subtaskData) {
                if (isset($subtaskData['id']) && is_numeric($subtaskData['id'])) {
                    $subtask = $todo->subtasks()->find($subtaskData['id']);
                    if ($subtask) {
                        $subtask->update([
                            'title' => $subtaskData['title'],
                            'is_completed' => $subtaskData['is_completed'] ?? $subtask->is_completed,
                        ]);
                        $inputSubtaskIds[] = $subtask->id;
                    }
                } else {
                    $newSubtask = $todo->subtasks()->create([
                        'title' => $subtaskData['title'],
                        'is_completed' => $subtaskData['is_completed'] ?? false,
                    ]);
                    $inputSubtaskIds[] = $newSubtask->id;
                }
            }

            // Optional: Delete subtasks that are not in the input
            $todo->subtasks()->whereNotIn('id', $inputSubtaskIds)->delete();
        }

        return $todo->load('subtasks');
    }

    public function logPomodoro($_, array $args): PomodoroSession
    {
        $session = PomodoroSession::create([
            'user_id' => Auth::id(),
            'type' => $args['type'],
            'duration_minutes' => $args['duration_minutes'],
            'started_at' => $args['started_at'],
            'completed_at' => now(),
            'status' => $args['status'] ?? 'completed',
            'todo_item_id' => $args['todo_item_id'] ?? null,
        ]);

        if ($session->status === 'completed' && $session->todo_item_id) {
            $todo = TodoItem::find($session->todo_item_id);
            if ($todo) {
                $todo->increment('completed_pomodoros');
            }
        }

        return $session;
    }

    public function createExam($_, array $args): ExamEvent
    {
        return ExamEvent::create([
            'user_id' => Auth::id(),
            'title' => $args['title'],
            'date' => $args['date'],
        ]);
    }

    public function updateExam($_, array $args): ExamEvent
    {
        $exam = ExamEvent::findOrFail($args['id']);

        // Ensure user owns the exam
        if ($exam->user_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $exam->update(array_intersect_key($args, array_flip(['title', 'date'])));
        return $exam;
    }

    public function history($_, array $args): \Illuminate\Database\Eloquent\Collection
    {
        return PomodoroSession::where('user_id', Auth::id())
            ->orderBy('started_at', 'desc')
            ->limit($args['limit'] ?? 10)
            ->with('todoItem')
            ->get();
    }
}
