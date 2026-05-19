<?php

namespace App\Models\Learn;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClinicalCaseNote extends Model
{
    protected $table = 'clinical_case_notes';

    protected $fillable = [
        'user_id',
        'clinical_case_id',
        'text',
        'thumbnail_url',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function clinical_case(): BelongsTo
    {
        return $this->belongsTo(ClinicalCase::class, 'clinical_case_id');
    }
}
