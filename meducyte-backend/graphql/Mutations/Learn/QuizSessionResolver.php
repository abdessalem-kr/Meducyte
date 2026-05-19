<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\QuizSession;
use App\Models\Learn\QuizAnswer;
use App\Models\Learn\Proposition;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;
use Illuminate\Support\Facades\DB;

class QuizSessionResolver
{
    /**
     * Start a new quiz session for one or multiple lessons
     * Mobile decides which lessons → full freedom
     */
    public function start($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();

        // Accept single lesson_id OR lesson_ids array
        if (isset($args['lesson_id'])) {
            $lessonIds = [$args['lesson_id']];
        } elseif (isset($args['lesson_ids'])) {
            $lessonIds = $args['lesson_ids'];
        } else {
            throw new \Exception('Either lesson_id or lesson_ids is required.');
        }

        // Optional: limit total questions (mobile can decide)
        $questionsPerLesson = $args['questions_per_lesson'] ?? null;

        return QuizSession::create([
            'user_id' => $user->id,
            'lesson_ids' => $lessonIds,           // ← JSON array of lesson IDs
            'questions_per_lesson' => $questionsPerLesson,
            'started_at' => now(),
        ]);
    }

    /**
     * Submit a single answer
     */
    public function submitAnswer($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();
        $sessionId = $args['session_id'];
        $questionId = $args['question_id'];
        $propositionId = $args['proposition_id'];

        $session = QuizSession::where('user_id', $user->id)
            ->where('id', $sessionId)
            ->whereNull('finished_at')
            ->firstOrFail();

        if (QuizAnswer::where('session_id', $sessionId)->where('question_id', $questionId)->exists()) {
            throw new \Exception('You already answered this question.');
        }

        $proposition = Proposition::findOrFail($propositionId);
        $isCorrect = $proposition->is_correct;

        return QuizAnswer::create([
            'session_id' => $sessionId,
            'question_id' => $questionId,
            'selected_proposition_id' => $propositionId,
            'is_correct' => $isCorrect,
            'answered_at' => now(),
        ]);
    }

    /**
     * Bulk submit answers (mobile-friendly)
     */
    public function submitBulk($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();
        $sessionId = $args['session_id'];
        $answers = $args['answers'];

        $session = QuizSession::where('user_id', $user->id)
            ->where('id', $sessionId)
            ->whereNull('finished_at')
            ->firstOrFail();

        DB::transaction(function () use ($sessionId, $answers, $session) {
            $correctCount = 0;

            foreach ($answers as $answer) {
                $questionId = $answer['question_id'];
                $propId = $answer['proposition_id'];

                if (QuizAnswer::where('session_id', $sessionId)->where('question_id', $questionId)->exists()) {
                    continue;
                }

                $prop = Proposition::findOrFail($propId);
                $isCorrect = $prop->is_correct;
                if ($isCorrect) $correctCount++;

                QuizAnswer::create([
                    'session_id' => $sessionId,
                    'question_id' => $questionId,
                    'selected_proposition_id' => $propId,
                    'is_correct' => $isCorrect,
                    'answered_at' => now(),
                ]);
            }

            $session->score = $correctCount;
            $session->total_questions = QuizAnswer::where('session_id', $sessionId)->count();
            $session->save();
        });

        return $session->fresh();
    }

    /**
     * Finish the quiz – calculate final score & percentage
     */
    public function finish($root, array $args, GraphQLContext $context, ResolveInfo $resolveInfo)
    {
        $user = auth('sanctum')->user();
        $sessionId = $args['session_id'];

        $session = QuizSession::with('answers')
            ->where('user_id', $user->id)
            ->where('id', $sessionId)
            ->whereNull('finished_at')
            ->firstOrFail();

        $correct = $session->answers->where('is_correct', true)->count();
        $total = $session->answers->count();

        $session->update([
            'score' => $correct,
            'total_questions' => $total,
            'percentage' => $total > 0 ? round(($correct / $total) * 100, 2) : 0,
            'finished_at' => now(),
        ]);

        return $session;
    }
}