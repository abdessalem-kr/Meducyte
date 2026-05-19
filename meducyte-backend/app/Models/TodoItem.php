<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TodoItem extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'priority',
        'deadline',
        'is_completed',
        'module_id',
        'estimated_pomodoros',
        'completed_pomodoros',
    ];

    protected $casts = [
        'is_completed' => 'boolean',
        'deadline' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function pomodoroSessions(): HasMany
    {
        return $this->hasMany(PomodoroSession::class);
    }

    public function subtasks(): HasMany
    {
        return $this->hasMany(SubTask::class);
    }
}
