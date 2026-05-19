<?php

namespace App\Models\StudyGroup;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudyGroupMessageReport extends Model
{
    protected $fillable = [
        'user_id',
        'message_id',
        'reason',
        'status',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function message(): BelongsTo
    {
        return $this->belongsTo(StudyGroupMessage::class, 'message_id');
    }
}
