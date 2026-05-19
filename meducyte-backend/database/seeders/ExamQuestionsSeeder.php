<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Learn\Question;
use App\Models\Learn\Concept;
use App\Models\Learn\Proposition;

class ExamQuestionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Define the path to your simple CSV file
        $csvFile = database_path('seeders/data/exam_questions.csv');
        $data = array_map('str_getcsv', file($csvFile));
        
        // Skip the header row
        $headers = array_shift($data); 

        $this->command->getOutput()->progressStart(count($data));

        DB::transaction(function () use ($data, $headers) {
            foreach ($data as $row) {
                // Map the CSV columns to an associative array
                $line = array_combine($headers, $row);

                // --- A. CREATE QUESTION ---
                $question = Question::create([
                    'lesson_id' => $line['lesson_id'],
                    'text' => $line['question_text'],
                    'source_exam' => $line['source_exam'],
                    'is_active' => true,
                    // Add other fields you recently created (review_date, creator_id, etc.)
                ]);

                // --- B. CREATE PROPOSITIONS & EXPLANATION ---
                $propositionsData = [
                    ['label' => 'A', 'text' => $line['prop_A']],
                    ['label' => 'B', 'text' => $line['prop_B']],
                    ['label' => 'C', 'text' => $line['prop_C']],
                    ['label' => 'D', 'text' => $line['prop_D']],
                ];
                $correctLabel = strtoupper($line['correct_answer']);

                $order = 1;
                foreach ($propositionsData as $prop) {
                    $isCorrect = ($prop['label'] === $correctLabel);
                    
                    Proposition::create([
                        'question_id' => $question->id,
                        'label' => $prop['label'],
                        'text' => $prop['text'],
                        'is_correct' => $isCorrect,
                        'order' => $order++,
                        // Explanation only goes on the correct answer row
                        'explanation_text' => $isCorrect ? $line['explanation'] : null, 
                    ]);
                }

                // --- C. ATTACH CONCEPTS (The Neural Network Link) ---
                if (!empty($line['concept_tags'])) {
                    $tags = array_map('trim', explode(',', $line['concept_tags']));
                    $conceptIds = [];

                    foreach ($tags as $conceptName) {
                        // Find or create the concept
                        $concept = Concept::firstOrCreate(['name' => $conceptName]);
                        $conceptIds[] = $concept->id;
                    }
                    $question->concepts()->attach($conceptIds); 
                }

                $this->command->getOutput()->progressAdvance();
            }
        });

        $this->command->getOutput()->progressFinish();
        $this->command->info("\nImported " . count($data) . " exam questions successfully.");
    }
}