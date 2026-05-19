<?php

namespace App\Models\StudyGroup;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudyGroupQuizSession extends Model
{
    protected $fillable = [
        'study_group_id',
        'title',
        'quiz_id',
        'questions',
        'scores',
        'status',
        'seconds_per_question',
    ];

    protected $casts = [
        'questions' => 'array',
        'scores' => 'object', // Must be 'object' not 'array': empty PHP array serializes as [] (JSON array),
        // but Dart expects {} (JSON object). 'object' cast always produces {}.
    ];

    public function group(): BelongsTo
    {
        return $this->belongsTo(StudyGroup::class, 'study_group_id');
    }
}
