<?php

namespace App\Models\Simulation;

use Illuminate\Database\Eloquent\Model;

class SimulationCase extends Model
{
    protected $casts = [
        'initial_vitals' => 'array',
        'physical_exam_results' => 'array',
        'lab_results' => 'array',
        'media_findings' => 'array',
        'expected_findings' => 'array',
    ];

    protected $fillable = [
        'pathology_id', 'name', 'age', 'gender', 'occupation',
        'main_complaint', 'medical_history', 'personality',
        'target_pathology', 'secret_details', 'initial_vitals',
        'physical_exam_results', 'lab_results', 'media_findings',
        'expected_findings'
    ];
}
