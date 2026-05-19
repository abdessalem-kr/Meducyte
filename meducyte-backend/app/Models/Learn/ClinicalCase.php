<?php

namespace App\Models\Learn;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ClinicalCase extends Model
{
    protected $table = 'clinical_cases';

    protected $fillable = [
        'lesson_id',
        'text',
        'title',
    ];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class);
    }

    public function highlights(): HasMany
    {
        return $this->hasMany(ClinicalCaseHighlight::class, 'clinical_case_id');
    }

    public function notes(): HasMany
    {
        return $this->hasMany(ClinicalCaseNote::class, 'clinical_case_id');
    }
}
