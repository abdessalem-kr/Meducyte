<?php

namespace App\Models\Learn;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ParagraphHighlight extends Model
{
    protected $table = 'paragraph_highlights';

    protected $fillable = [
        'user_id',
        'paragraph_id',
        'highlights',
    ];

    protected $casts = [
        'highlights' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function paragraph(): BelongsTo
    {
        return $this->belongsTo(LessonParagraph::class, 'paragraph_id');
    }
}
