<?php
// app/Models/Learn/ParagraphNote.php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ParagraphNote extends Model
{
    protected $table = 'paragraph_notes';

    protected $fillable = [
        'user_id',
        'paragraph_id',
        'text',
        'google_drive_file_id',
        'google_drive_web_view_link',
        'thumbnail_url',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class);
    }

    public function paragraph(): BelongsTo
    {
        return $this->belongsTo(LessonParagraph::class);
    }
}