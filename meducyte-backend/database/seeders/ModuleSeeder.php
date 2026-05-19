<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Learn\Module;

class ModuleSeeder extends Seeder
{
    public function run(): void
    {
        // --- YEAR 1 ---
        $year1Modules = [
            'Anatomie',
            'Biochimie',
            'Biophysique',
            'Chimie',
            'Cytologie',
            'Biostatistiques et Informatique',
            'Embryologie',
            'Histologie',
            'Physiologie',
            'Santé, Société et Humanité (SSH)',
            'Langue (Anglais/Français Médical)'
        ];

        foreach ($year1Modules as $name) {
            Module::updateOrCreate(['name' => $name], ['year' => 1]);
        }

        // --- YEAR 2 ---
        $year2UEIs = [
            'UEI 1: Cardio-respiratoire et Organes Hématopoïétiques' => [
                'Biophysique (Cardio-respiratoire)',
                'Anatomie (Cardio-respiratoire)',
                'Histologie (Cardio-respiratoire)',
                'Physiologie (Cardio-respiratoire)'
            ],
            'UEI 2: Appareil Digestif' => [
                'Anatomie (Digestif)',
                'Histologie (Digestif)',
                'Physiologie (Digestif)',
                'Biochimie (Digestif)'
            ],
            'UEI 3: Appareil Urinaire' => [
                'Anatomie (Urinaire)',
                'Histologie (Urinaire)',
                'Physiologie (Urinaire)',
                'Biochimie (Urinaire)'
            ],
            'UEI 4: Appareil Endocrinien et Génital' => [
                'Anatomie (Endocrinien et Génital)',
                'Histologie (Endocrinien et Génital)',
                'Physiologie (Endocrinien et Génital)',
                'Biochimie (Endocrinien et Génital)'
            ],
            'UEI 5: Système Nerveux et Organes des Sens' => [
                'Biophysique (Système Nerveux)',
                'Anatomie (Système Nerveux)',
                'Histologie (Système Nerveux)',
                'Physiologie (Système Nerveux)'
            ],
        ];

        foreach ($year2UEIs as $ueiName => $children) {
            $parent = Module::updateOrCreate(['name' => $ueiName], ['year' => 2, 'parent_id' => null]);
            foreach ($children as $childName) {
                Module::updateOrCreate(['name' => $childName], ['year' => 2, 'parent_id' => $parent->id]);
            }
        }

        // Transversal Year 2
        Module::updateOrCreate(['name' => 'Immunologie'], ['year' => 2]);
        Module::updateOrCreate(['name' => 'Génétique'], ['year' => 2]);

        // --- YEAR 3 ---
        $year3UEIs = [
            'UEI 1: Psychologie Médicale, Sémiologie Générale, Appareil Cardio-vasculaire et Respiratoire' => [
                'Sémiologie Clinique',
                'Physiopathologie',
                'Imagerie-Radiologie',
                'Biochimie'
            ],
            'UEI 2: Appareil Neurologique, Locomoteur et Cutané' => [
                'Sémiologie Clinique',
                'Physiopathologie',
                'Imagerie-Radiologie',
                'Biochimie'
            ],
            'UEI 3: Appareil Endocrinien, de Reproduction et Urinaire' => [
                'Sémiologie Clinique',
                'Physiopathologie',
                'Imagerie-Radiologie',
                'Biochimie'
            ],
            'UEI 4: Appareil Digestif et Organes Hématopoïétiques' => [
                'Sémiologie Clinique',
                'Physiopathologie',
                'Imagerie-Radiologie',
                'Biochimie'
            ]
        ];

        foreach ($year3UEIs as $ueiName => $children) {
            $parent = Module::updateOrCreate(['name' => $ueiName], ['year' => 3, 'parent_id' => null]);
            foreach ($children as $childName) {
                // To allow unique modules with same name under different UEIs if needed, 
                // but here matching by name AND parent_id is safer for seeding.
                Module::updateOrCreate(
                    ['name' => $childName, 'parent_id' => $parent->id],
                    ['year' => 3]
                );
            }
        }

        // Transversal Year 3
        $year3Transversal = [
            'Anatomie Pathologiques',
            'Pharmacologie Clinique',
            'Microbiologie Médicale',
            'Parasitologie et Mycologie',
            'Immunologie'
        ];
        foreach ($year3Transversal as $name) {
            Module::updateOrCreate(['name' => $name], ['year' => 3]);
        }

        // --- YEARS 4-5 (Standard list) ---
        $advancedModules = [
            4 => ['Cardiologie', 'Pneumologie', 'Neurologie', 'Gastro-entérologie', 'Maladies Infectieuses', 'Hématologie'],
            5 => ['Pédiatrie', 'Gynécologie-Obstétrique', 'Orthopédie-Traumatologie', 'Urologie', 'Néphrologie', 'Endocrinologie-Diabétologie', 'Psychiatrie'],
        ];

        foreach ($advancedModules as $year => $names) {
            foreach ($names as $name) {
                Module::updateOrCreate(['name' => $name], ['year' => $year]);
            }
        }

        // --- YEAR 6 ---
        $year6Modules = [
            'Ophtalmologie',
            'ORL',
            'Dermatologie',
            'Maladies Systémiques',
            'Épidémiologie',
            'Médecine du Travail',
            'Médecine Légale et Droit Médical',
            'Médecine d\'Urgence',
            'Gériatrie'
        ];
        foreach ($year6Modules as $name) {
            Module::updateOrCreate(['name' => $name], ['year' => 6]);
        }
    }
}