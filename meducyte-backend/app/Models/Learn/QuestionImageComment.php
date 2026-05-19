<?php
// app/Models/Learn/QuestionImageComment.php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuestionImageComment extends Model
{
    protected $table = 'question_image_comments';

    protected $fillable = [
        'user_id',
        'question_id',
        'google_drive_file_id',
        'google_drive_web_view_link',
        'thumbnail_url',
        'caption',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class);
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(Question::class);
    }
}