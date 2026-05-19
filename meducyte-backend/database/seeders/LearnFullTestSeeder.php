<?php
// database/seeders/LearnFullTestSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Learn\Module;
use App\Models\Learn\Lesson;
use App\Models\Learn\LessonParagraph;
use App\Models\Learn\Question;
use App\Models\Learn\Proposition;
use App\Models\Learn\ParagraphNote;
use App\Models\Learn\QuestionImageComment;

class LearnFullTestSeeder extends Seeder
{
    public function run(): void
    {
        // Disable foreign key checks to allow deletion
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Safe delete in correct order (child tables first)
        ParagraphNote::query()->delete();
        QuestionImageComment::query()->delete();
        Proposition::query()->delete();
        Question::query()->delete();
        LessonParagraph::query()->delete();
        Lesson::query()->delete();
        Module::query()->delete();

        // Re-enable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Create test user
        $user = User::firstOrCreate(
            ['email' => 'test@meducyte.com'],
            [
                'name' => 'Test Doctor',
                'email' => 'test@meducyte.com',
                'password' => Hash::make('password'),
            ]
        );

        // 1. Module
        $module = Module::create([
            'name' => 'Cardiologie - Année 3',
            'description' => 'Cours complet sur le cycle cardiaque et l\'hémodynamique',
            'year' => 3,
        ]);

        // 2. Lesson
        $lesson = Lesson::create([
            'module_id' => $module->id,
            'title' => 'Le Cycle Cardiaque',
            'order' => 1,
        ]);

        // 3. Paragraphs
        $paragraph1 = LessonParagraph::create([
            'lesson_id' => $lesson->id,
            'content' => 'La systole auriculaire correspond à la contraction des oreillettes qui pousse le sang vers les ventricules. Cette phase assure le remplissage ventriculaire pendant la diastole ventriculaire.',
            'order' => 1,
        ]);

        $paragraph2 = LessonParagraph::create([
            'lesson_id' => $lesson->id,
            'content' => 'La systole ventriculaire est la phase d\'éjection où les ventricules se contractent, expulsant le sang dans l\'aorte (gauche) et l\'artère pulmonaire (droite). La pression ventriculaire atteint son pic systolique.',
            'order' => 2,
        ]);

        // 4. Questions + Propositions
        $question1 = Question::create([
            'lesson_id' => $lesson->id,
            'paragraph_id' => $paragraph1->id,
            'text' => 'Pendant la systole auriculaire, quel est le rôle principal des oreillettes ?',
            'source_exam' => 'ECN 2023 - QCM Cardiologie',
            'tags' => json_encode(['systole', 'oreillettes', 'remplissage']),
            'estimated_time' => 45,
            'approved' => true,
        ]);

        Proposition::create(['question_id' => $question1->id, 'label' => 'A', 'text' => 'Contraction des ventricules pour l\'éjection sanguine', 'is_correct' => false, 'order' => 1]);
        Proposition::create(['question_id' => $question1->id, 'label' => 'B', 'text' => 'Contraction des oreillettes pour remplir les ventricules', 'is_correct' => true, 'order' => 2]);
        Proposition::create(['question_id' => $question1->id, 'label' => 'C', 'text' => 'Relaxation complète du cœur', 'is_correct' => false, 'order' => 3]);

        $question2 = Question::create([
            'lesson_id' => $lesson->id,
            'paragraph_id' => $paragraph2->id,
            'text' => 'La pression maximale dans le ventricule gauche pendant la systole ventriculaire correspond à :',
            'source_exam' => 'ECN 2022 - Hémodynamique',
            'tags' => json_encode(['systole', 'pression', 'ventricule']),
            'estimated_time' => 30,
            'approved' => true,
        ]);

        Proposition::create(['question_id' => $question2->id, 'label' => 'A', 'text' => 'La pression diastolique (relaxation)', 'is_correct' => false, 'order' => 1]);
        Proposition::create(['question_id' => $question2->id, 'label' => 'B', 'text' => 'La pression systolique (contraction)', 'is_correct' => true, 'order' => 2]);
        Proposition::create(['question_id' => $question2->id, 'label' => 'C', 'text' => 'La pression moyenne artérielle', 'is_correct' => false, 'order' => 3]);

        // 5. Private note
        ParagraphNote::create([
            'user_id' => $user->id,
            'paragraph_id' => $paragraph1->id,
            'text' => 'Note privée: Associer systole auriculaire = "remplissage ventriculaire" pour ECN.',
        ]);

        // 6. Public image comment
        QuestionImageComment::create([
            'user_id' => $user->id,
            'question_id' => $question1->id,
            'google_drive_file_id' => '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms',
            'google_drive_web_view_link' => 'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view?usp=sharing',
            'thumbnail_url' => 'https://drive.google.com/thumbnail?id=1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms',
            'caption' => 'Schéma du cycle cardiaque (image partagée publiquement)',
        ]);

        $this->command->info('SEEDER RAN SUCCESSFULLY — NO ERRORS!');
        $this->command->info("Lesson ID: {$lesson->id}");
        $this->command->info("Paragraph 1 ID: {$paragraph1->id} (has_quiz + note)");
        $this->command->info("Paragraph 2 ID: {$paragraph2->id}");
        $this->command->info("Question 1 ID: {$question1->id} (has image comment)");
        $this->command->info("Question 2 ID: {$question2->id}");
        $this->command->info("Login: test@meducyte.com / password");
    }
}