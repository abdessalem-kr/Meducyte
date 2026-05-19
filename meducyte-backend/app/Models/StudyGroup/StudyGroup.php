<?php

namespace App\Models\StudyGroup;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class StudyGroup extends Model
{
    protected $fillable = [
        'title',
        'description',
        'color',
        'type',
        'active_quiz_session_id',
    ];

    public function members(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'study_group_members')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function messages(): HasMany
    {
        return $this->hasMany(StudyGroupMessage::class);
    }

    public function quizSessions(): HasMany
    {
        return $this->hasMany(StudyGroupQuizSession::class);
    }

    public function activeSession(): HasOne
    {
        return $this->hasOne(StudyGroupQuizSession::class, 'id', 'active_quiz_session_id');
    }
}
