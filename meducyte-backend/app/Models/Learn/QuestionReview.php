<?php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class QuestionReview extends Model
{
    use HasFactory;

    protected $table = 'question_reviews';

    protected $fillable = [
        'user_id',
        'question_id',
        'interval',
        'ease_factor',
        'repetition_count',
        'next_review',
        'last_review',
    ];

    protected $casts = [
        'next_review' => 'datetime',
        'last_review' => 'datetime',
        'ease_factor' => 'double',
        'interval' => 'integer',
        'repetition_count' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function question()
    {
        return $this->belongsTo(Question::class);
    }

    // Explicit accessors to help Lighthouse serialize the renamed camelCase fields safely
    public function getUserIdAttribute() { return $this->attributes['user_id']; }
    public function getQuestionIdAttribute() { return $this->attributes['question_id']; }
    public function getEaseFactorAttribute() { return $this->attributes['ease_factor']; }
    public function getRepetitionCountAttribute() { return $this->attributes['repetition_count']; }
    public function getNextReviewAttribute() { return $this->attributes['next_review']; }
    public function getLastReviewAttribute() { return $this->attributes['last_review'] ?? null; }
}
