<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Simulation\SimulationCase;

class SimulationCaseSeeder extends Seeder
{
    public function run()
    {
        // 1. Acute Myocardial Infarction (STEMI)
        SimulationCase::updateOrCreate(
            ['pathology_id' => 'stemi'],
            [
                'module_name' => 'Cardiology',
                'name' => 'John Doe',
                'age' => 58,
                'gender' => 'M',
                'occupation' => 'Taxi Driver',
                'summary' => "58yo Male, Taxi Driver. Presents with sudden onset crushing chest pain and diaphoresis.",
                'main_complaint' => 'Substernal chest pain and diaphoresis.',
                'medical_history' => 'Hypertension, Dyslipidemia, Smoker',
                'personality' => 'Anxious',
                'target_pathology' => 'Acute Myocardial Infarction',
                'secret_details' => 'Pain radiates to the left arm.',
                'initial_vitals' => [
                    'heart_rate' => 105,
                    'blood_pressure' => '150/95',
                    'temperature' => 37.0,
                    'spo2' => 94,
                    'respiratory_rate' => 22
                ],
                'physical_exam_results' => [
                    'Auscultation' => 'Cardiac Auscultation: Mitral, Tricuspid, Aortic, and Pulmonic areas.',
                    'Palpation' => 'Precordial Palpation: Apex beat and parasternal areas.',
                ],
                'lab_results' => [
                    'ECG (12-Lead)' => '12-Lead ECG: Standard leads (I, II, III, aVR, aVL, aVF, V1-V6).',
                    'Troponin I/T' => "Parameter | Value | Reference\nTroponin I | 450 ng/L | < 14 ng/L",
                    'Full Blood Count' => "Parameter | Value | Reference\nWBC | 11.2 | 4.0-11.0\nHb | 13.5 | 13.0-17.0\nPlt | 320 | 150-400",
                    'Chest X-Ray' => 'Chest X-Ray: Posteroanterior (PA) view.',
                ],
                'media_findings' => [
                    'Auscultation' => [
                        'url' => 'https://www.med.umich.edu/lrc/psb_open/html/repo/sounds/s4_gallop.mp3',
                        'type' => 'audio',
                        'title' => 'Heart Auscultation'
                    ],
                    'ECG (12-Lead)' => [
                        'url' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Anterior_wall_infarction_-_ECG.jpg/1280px-Anterior_wall_infarction_-_ECG.jpg',
                        'type' => 'ecg',
                        'title' => '12-Lead ECG Trace'
                    ],
                ],
                'expected_findings' => ['ST elevation', 'Elevated Troponin'],
            ]
        );

        // 2. Pneumonia
        SimulationCase::updateOrCreate(
            ['pathology_id' => 'pneumonia'],
            [
                'module_name' => 'Respiratory',
                'name' => 'Sarah Miller',
                'age' => 65,
                'gender' => 'F',
                'occupation' => 'Retired Teacher',
                'summary' => "65yo Female, Retired Teacher. High fever, productive cough, and pleuritic chest pain for 48 hours.",
                'main_complaint' => 'Cough, fever, and right-sided chest pain.',
                'medical_history' => 'COPD, Type 2 Diabetes',
                'personality' => 'Stoic',
                'target_pathology' => 'Pneumonia',
                'secret_details' => 'Pain is pleuritic (worse on deep breath).',
                'initial_vitals' => [
                    'heart_rate' => 110,
                    'blood_pressure' => '115/75',
                    'temperature' => 38.8,
                    'spo2' => 91,
                    'respiratory_rate' => 26
                ],
                'physical_exam_results' => [
                    'Auscultation' => 'Respiratory Auscultation: Anterior and posterior chest wall fields.',
                    'Percussion' => 'Thoracic Percussion: Resonant and dull areas noted.',
                ],
                'lab_results' => [
                    'Chest X-Ray' => 'Chest X-Ray: Anteroposterior (AP) view.',
                    'Full Blood Count' => "Parameter | Value | Reference\nWBC | 18.5 | 4.0-11.0\nNeutrophils | 88% | 40-75%",
                    'CRP' => "Parameter | Value | Reference\nCRP | 150 mg/L | < 5 mg/L",
                ],
                'media_findings' => [
                    'Chest X-Ray' => [
                        'url' => 'https://upload.wikimedia.org/wikipedia/commons/a/a1/Normal_posteroanterior_chest_X-ray.jpg',
                        'type' => 'image',
                        'title' => 'Chest Cliché PA'
                    ],
                ],
                'expected_findings' => ['Crackles', 'Consolidation'],
            ]
        );
    }
}
