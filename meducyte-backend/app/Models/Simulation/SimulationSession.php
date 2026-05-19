<?php

namespace App\Models\Simulation;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use App\Models\User;

class SimulationSession extends Model
{
    use HasUuids;

    protected $casts = [
        'current_vitals' => 'array',
        'is_finished' => 'boolean',
    ];

    protected $fillable = [
        'user_id', 'simulation_case_id', 'difficulty',
        'setting', 'is_finished', 'score', 'feedback', 'current_vitals'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function case()
    {
        return $this->belongsTo(SimulationCase::class, 'simulation_case_id');
    }

    public function messages()
    {
        return $this->hasMany(SimulationMessage::class, 'session_id');
    }
}
