<?php

namespace App\Models\Learn;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuestionComment extends Model
{
    protected $table = 'question_comments';

    protected $fillable = [
        'user_id',
        'question_id',
        'parent_id',
        'text',
        'is_edited',
        'upvotes',
        'downvotes',
    ];

    protected $casts = [
        'is_edited' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(Question::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(QuestionComment::class, 'parent_id');
    }

    public function replies()
    {
        return $this->hasMany(QuestionComment::class, 'parent_id');
    }

    public function votes()
    {
        return $this->hasMany(CommentVote::class, 'comment_id');
    }
}
