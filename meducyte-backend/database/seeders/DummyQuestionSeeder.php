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
        $this->command->info('Starting 40,000 dummy questions seeding...');

        // 1. Disable foreign key checks for fast clean-up if needed
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // 2. Find or create the Load Testing module & lesson
        $module = Module::firstOrCreate(
            ['name' => 'Load Testing & Performance'],
            [
                'description' => 'Module dedicated to database performance and load testing with dummy data.',
                'year' => 1,
            ]
        );

        $lesson = Lesson::firstOrCreate(
            ['title' => '40k Dummy Questions Load Test', 'module_id' => $module->id],
            [
                'order' => 999,
            ]
        );

        // 3. Re-enable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $startTime = microtime(true);

        // 4. Perform transaction for high speed
        DB::transaction(function () use ($lesson) {
            $totalQuestions = 40000;
            $propositionsData = [];
            $now = now();

            for ($i = 1; $i <= $totalQuestions; $i++) {
                // Insert question and get ID (100% database-agnostic and robust inside transaction)
                $questionId = DB::table('questions')->insertGetId([
                    'lesson_id' => $lesson->id,
                    'text' => "This is dummy test question number {$i} to evaluate server database performance under heavy loads.",
                    'source_exam' => 'Load Test ' . date('Y'),
                    'tags' => json_encode(['dummy', 'loadtest', 'performance']),
                    'estimated_time' => 30,
                    'approved' => true,
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
                        'text' => "Proposition {$label} for dummy question {$questionId}.",
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
        $this->command->info("Seeded 40,000 questions and 160,000 propositions successfully in {$duration} seconds!");
    }
}
