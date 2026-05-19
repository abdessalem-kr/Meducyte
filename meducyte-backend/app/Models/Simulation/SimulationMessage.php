<?php

namespace App\Models\Simulation;

use Illuminate\Database\Eloquent\Model;

class SimulationMessage extends Model
{
    protected $casts = [
        'media' => 'array',
        'is_from_user' => 'boolean',
        'is_revealed' => 'boolean',
        'timestamp' => 'datetime',
    ];

    protected $fillable = [
        'session_id', 'text', 'is_from_user', 'media',
        'raw_result', 'interpretation', 'is_revealed', 'timestamp'
    ];

    public function session()
    {
        return $this->belongsTo(SimulationSession::class, 'session_id');
    }
}
