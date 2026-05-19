<?php

namespace Database\Seeders;

use App\Models\StudyGroup\StudyGroup;
use Illuminate\Database\Seeder;

class StudyGroupSeeder extends Seeder
{
    public function run(): void
    {
        StudyGroup::create([
            'title' => 'Bibliothèque de Médecine',
            'description' => 'Silence strict. Deep work uniquement.',
            'color' => '#4A90E2',
            'type' => 'silent',
        ]);

        StudyGroup::create([
            'title' => 'Lofi Study Session ☕',
            'description' => 'Musique douce et ambiance chill.',
            'color' => '#6366F1',
            'type' => 'focus',
        ]);

        StudyGroup::create([
            'title' => 'QCM Battle Royale ⚔️',
            'description' => 'Compétition intense sur les derniers sujets.',
            'color' => '#F87171',
            'type' => 'qcmBattle',
        ]);
    }
}
