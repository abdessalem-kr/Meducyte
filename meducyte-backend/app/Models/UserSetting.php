<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSetting extends Model
{
    protected $fillable = [
        'user_id',
        'pomodoro_work_duration',
        'pomodoro_short_break',
        'pomodoro_long_break',
        'pomodoro_sessions_until_long_break',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
