<?php
// app/Models/Learn/LessonParagraph.php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LessonParagraph extends Model
{
    use HasFactory;

    protected $table = 'lesson_paragraphs';

    protected $fillable = [
        'lesson_id',
        'title',
        'content',
        'order',
    ];

    protected $casts = [
        'order' => 'integer',
    ];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class, 'paragraph_id');
    }

    public function notes(): HasMany
    {
        return $this->hasMany(ParagraphNote::class, 'paragraph_id');
    }
}