<?php
// app/Models/Learn/Question.php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Question extends Model
{
    protected $table = 'questions';

    protected $fillable = [
        'lesson_id',
        'paragraph_id',
        'clinical_case_id',
        'text',
        'source_exam',
        'tags',
        'estimated_time',
        'approved',
    ];

    protected $casts = [
        'tags' => 'array',
        'approved' => 'boolean',
    ];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }

    public function paragraph(): BelongsTo
    {
        return $this->belongsTo(LessonParagraph::class, 'paragraph_id');
    }

    public function clinical_case(): BelongsTo
    {
        return $this->belongsTo(ClinicalCase::class, 'clinical_case_id');
    }

    public function propositions(): HasMany
    {
        return $this->hasMany(Proposition::class)->orderBy('order');
    }

    /**
     * THIS WAS THE BUG — missing foreign key!
     * Your column is called `question_id` in question_image_comments table
     */
    public function image_comments(): HasMany
    {
        return $this->hasMany(QuestionImageComment::class, 'question_id');
    }

    public function comments(): HasMany
    {
        return $this->hasMany(QuestionComment::class, 'question_id')->orderBy('created_at', 'asc');
    }

    public function highlights(): HasMany
    {
        return $this->hasMany(QuestionHighlight::class, 'question_id');
    }

    public function getLessonTitleAttribute(): ?string
    {
        return $this->lesson?->title;
    }

    public function getModuleNameAttribute(): ?string
    {
        return $this->lesson?->module?->name;
    }

    public function getYearAttribute(): ?int
    {
        return $this->lesson?->module?->year;
    }
}