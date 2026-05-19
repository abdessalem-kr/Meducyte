<?php
namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Proposition extends Model
{
    protected $table = 'propositions';

    protected $fillable = [
        'question_id',
        'label',
        'text',
        'is_correct',
        'order',
    ];

    protected $casts = [
        'is_correct' => 'boolean',
    ];

    // ADD THIS - explicit accessor for GraphQL
    public function getIsCorrectAttribute()
    {
        return (bool) $this->attributes['is_correct'];
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(Question::class);
    }
}