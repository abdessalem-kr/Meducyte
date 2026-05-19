<?php

namespace App\Models\Learn;

use App\Enums\BlockType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class LessonBlock extends Model
{
    protected $guarded = ['id'];

    // 1. Auto-convert 'type' string to Enum
    protected $casts = [
        'type' => BlockType::class,
        'meta' => 'array', // Auto-convert JSON to Array
    ];

    public function lesson()
    {
        return $this->belongsTo(Lesson::class);
    }

    // The Deep Link to questions
    public function questions(): BelongsToMany
    {
        return $this->belongsToMany(Question::class, 'lesson_block_question');
    }

    // The Link to concepts (Smart Reader)
    public function concepts(): BelongsToMany
    {
        return $this->belongsToMany(Concept::class, 'concept_lesson_block');
    }
}