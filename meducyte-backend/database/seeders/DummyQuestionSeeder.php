<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Learn\Module;
use App\Models\Learn\Lesson;

class DummyQuestionSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('Starting 40,000 realistic dummy questions seeding...');

        // 1. Check if modules exist
        if (Module::count() === 0) {
            $this->command->info('No modules found in the database. Running ModuleSeeder first...');
            $this->call(ModuleSeeder::class);
        }

        $modules = Module::all();
        $this->command->info('Found ' . $modules->count() . ' modules in the database.');

        // 2. Generate 25 to 40 dummy lessons for each module in bulk
        $this->command->info('Generating 25 to 40 dummy lessons for each module...');
        
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        $now = now();
        $lessonsToInsert = [];
        
        foreach ($modules as $module) {
            $lessonCount = rand(25, 40);
            for ($l = 1; $l <= $lessonCount; $l++) {
                $lessonsToInsert[] = [
                    'module_id' => $module->id,
                    'title' => "{$module->name} - Leçon {$l}",
                    'order' => $l,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }
            
            // Insert lessons in batches of 1,000 to keep execution fast and low-memory
            if (count($lessonsToInsert) >= 1000) {
                DB::table('lessons')->insert($lessonsToInsert);
                $lessonsToInsert = [];
            }
        }

        // Insert remaining lessons
        if (count($lessonsToInsert) > 0) {
            DB::table('lessons')->insert($lessonsToInsert);
        }
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 3. Eager load all lessons with their parent modules for ultra-fast reference
        $lessonsList = Lesson::with('module')->get();
        $lessonsCount = $lessonsList->count();
        $this->command->info("Total lessons in database (ready to host questions): {$lessonsCount}");

        // 4. Define variation pools for realistic filters
        $sources = [
            'ECN 2020',
            'ECN 2021',
            'ECN 2022',
            'ECN 2023',
            'Sidi Bel Abbes Résidanat 2024',
            'Algiers Résidanat 2023',
            'Oran Medical Exam',
            'Constantine Internal Test',
            'Faculté de Médecine 2025',
        ];

        $medicalTags = [
            'Cardiologie' => ['cardio', 'insuffisance-cardiaque', 'valvulopathie', 'ecg', 'hypertension', 'infarctus', 'arythmie'],
            'Pneumologie' => ['pneumo', 'asthme', 'bpco', 'pneumonie', 'tuberculose', 'pleurésie', 'embolie'],
            'Neurologie' => ['neuro', 'avc', 'épilepsie', 'migraine', 'parkinson', 'sclérose', 'démence'],
            'Gastro-entérologie' => ['gastro', 'ulcère', 'hépatite', 'cirrhose', 'reflux', 'colite', 'pancréatite'],
            'Pédiatrie' => ['pédiatrie', 'croissance', 'vaccination', 'néonatologie', 'bronchiolite', 'méningite'],
            'Gynécologie-Obstétrique' => ['gynéco', 'grossesse', 'accouchement', 'contraception', 'ménopause', 'fibrome'],
            'Anatomie' => ['anatomie', 'ostéologie', 'myologie', 'arthrologie', 'système-nerveux', 'thorax'],
            'Biochimie' => ['biochimie', 'enzymes', 'métabolisme', 'protéines', 'lipides', 'glucides', 'cycle-krebs'],
            'Physiologie' => ['physiologie', 'potentiel-action', 'filtration-glomérulaire', 'ventilation', 'synapse'],
        ];

        $questionTemplates = [
            "Concernant le cours [Lesson], quelle est la proposition exacte à propos du diagnostic ou de la prise en charge (QCM N°[Index]) ?",
            "Parmi les éléments suivants concernant [Lesson], déterminez la réponse correcte (Question [Index]) :",
            "Une question d'évaluation sur [Lesson] - Module [Module] (Numéro d'exercice : [Index]).",
            "Quel est le mécanisme physiopathologique principal décrit dans [Lesson] ? (QCM [Index])",
            "Dans le cadre de [Lesson], quel examen complémentaire de première intention est le plus adapté ? (QCM [Index])",
            "Concernant les critères diagnostiques de [Lesson], quelle affirmation est vraie ? (Question [Index])",
        ];

        $startTime = microtime(true);

        // 5. Perform transaction for high speed
        DB::transaction(function () use ($lessonsList, $lessonsCount, $sources, $medicalTags, $questionTemplates) {
            $totalQuestions = 40000;
            $propositionsData = [];
            $now = now();

            for ($i = 1; $i <= $totalQuestions; $i++) {
                // Distribute question sequentially across lessons
                $lesson = $lessonsList[$i % $lessonsCount];
                $module = $lesson->module;
                
                // Dynamic template resolution
                $template = $questionTemplates[$i % count($questionTemplates)];
                $questionText = str_replace(
                    ['[Lesson]', '[Module]', '[Index]'],
                    [$lesson->title, $module->name, $i],
                    $template
                );

                // Select tags based on the module
                $tags = ['qcm', 'cours'];
                $moduleName = $module->name;
                foreach ($medicalTags as $key => $tagPool) {
                    if (str_contains(strtolower($moduleName), strtolower($key))) {
                        shuffle($tagPool);
                        $tags = array_merge($tags, array_slice($tagPool, 0, 2));
                        break;
                    }
                }
                $tags[] = strtolower(str_replace([' ', '-', '\''], '', $moduleName));

                // Insert question and get ID (100% database-agnostic and robust)
                $questionId = DB::table('questions')->insertGetId([
                    'lesson_id' => $lesson->id,
                    'text' => $questionText,
                    'source_exam' => $sources[$i % count($sources)],
                    'tags' => json_encode(array_values(array_unique($tags))),
                    'estimated_time' => [30, 45, 60, 90, 120][$i % 5],
                    'approved' => ($i % 25 !== 0), // 96% approved, 4% pending
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);

                // Generate 4 propositions (A, B, C, D)
                $correctIndex = rand(0, 3);
                $labels = ['A', 'B', 'C', 'D'];

                foreach ($labels as $index => $label) {
                    $propositionsData[] = [
                        'question_id' => $questionId,
                        'label' => $label,
                        'text' => "Proposition {$label} concernant les caractéristiques de [{$lesson->title}].",
                        'is_correct' => ($index === $correctIndex),
                        'order' => $index + 1,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ];
                }

                // Batch insert propositions to prevent memory bloat
                if (count($propositionsData) >= 2000) {
                    DB::table('propositions')->insert($propositionsData);
                    $propositionsData = [];
                }

                // Progress update console output
                if ($i % 5000 === 0) {
                    $this->command->info("Seeded {$i} questions...");
                }
            }

            // Insert remaining propositions
            if (count($propositionsData) > 0) {
                DB::table('propositions')->insert($propositionsData);
            }
        });

        $duration = round(microtime(true) - $startTime, 2);
        $this->command->info("Seeded 40,000 realistic medical questions and 160,000 propositions successfully across {$lessonsCount} lessons in {$duration} seconds!");
    }
}
