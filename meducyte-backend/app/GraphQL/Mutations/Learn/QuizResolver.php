<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\Question;
use App\Models\Learn\Proposition;
use App\Models\Learn\UserAnswer;
use App\Models\Learn\QuestionReview;
use Illuminate\Support\Facades\Auth;

class QuizResolver
{
    public function submit($root, array $args)
    {
        $user = Auth::user();
        $question = Question::findOrFail($args['questionId']);
        $proposition = Proposition::findOrFail($args['propositionId']);

        $isCorrect = $proposition->is_correct;

        // Record the answer
        UserAnswer::updateOrCreate(
            [
                'user_id' => $user->id,
                'question_id' => $question->id,
            ],
            [
                'proposition_id' => $proposition->id,
                'is_correct' => $isCorrect,
            ]
        );

        $correctProposition = $question->propositions()->where('is_correct', true)->first();

        return [
            'isCorrect' => $isCorrect,
            'correctPropositionId' => $correctProposition?->id,
            'explanation' => 'Placeholder explanation for now.',
        ];
    }

    public function sync($root, array $args)
    {
        $logFile = storage_path('logs/debug.log');
        try {
            file_put_contents($logFile, "[DEBUG] syncQuizSession called\n", FILE_APPEND);
            $user = Auth::user();
            if (!$user) {
                file_put_contents($logFile, "[DEBUG] syncQuizSession: No user authenticated\n", FILE_APPEND);
                return false;
            }

            $results = $args['results'];
            file_put_contents($logFile, "[DEBUG] syncQuizSession payload: " . json_encode($results) . "\n", FILE_APPEND);
            
            // Handle if $results is a JSON string instead of an array (common GraphQL JSON scalar issue)
            if (is_string($results)) {
                $results = json_decode($results, true);
                file_put_contents($logFile, "[DEBUG] syncQuizSession decoded string payload: " . json_encode($results) . "\n", FILE_APPEND);
            }

            $userAnswers = $results['user_answers'] ?? [];
            file_put_contents($logFile, "[DEBUG] syncQuizSession found " . count($userAnswers) . " user_answers\n", FILE_APPEND);

            foreach ($userAnswers as $questionId => $propositionIds) {
                if (empty($propositionIds)) {
                    continue;
                }

                $propositionId = $propositionIds[0];
                file_put_contents($logFile, "[DEBUG] Processing Question: $questionId, Prop: $propositionId\n", FILE_APPEND);
                $proposition = Proposition::find($propositionId);
                
                if ($proposition) {
                    // 1. Record the raw answer
                    UserAnswer::updateOrCreate(
                        [
                            'user_id' => $user->id,
                            'question_id' => $questionId,
                        ],
                        [
                            'proposition_id' => $propositionId,
                            'is_correct' => $proposition->is_correct,
                        ]
                    );
                    file_put_contents($logFile, "[DEBUG] UserAnswer saved\n", FILE_APPEND);

                    // 2. Automatically feed this into the Spaced Repetition System (question_reviews)
                    $existingReview = QuestionReview::where('user_id', $user->id)
                        ->where('question_id', $questionId)
                        ->first();

                    if ($proposition->is_correct) {
                        $newRepCount = ($existingReview ? $existingReview->repetition_count : 0) + 1;
                        $newInterval = $existingReview ? max(1, $existingReview->interval * 2) : 1;
                        $newEase = $existingReview ? $existingReview->ease_factor : 2.5;
                    } else {
                        $newRepCount = 0;
                        $newInterval = 0;
                        $newEase = $existingReview ? max(1.3, $existingReview->ease_factor - 0.20) : 2.5;
                    }

                    $nextReviewDate = now()->addDays(max(0, $newInterval));

                    QuestionReview::updateOrCreate(
                        [
                            'user_id' => $user->id,
                            'question_id' => $questionId,
                        ],
                        [
                            'interval' => $newInterval,
                            'ease_factor' => $newEase,
                            'repetition_count' => $newRepCount,
                            'next_review' => $nextReviewDate,
                            'last_review' => now(),
                        ]
                    );
                    file_put_contents($logFile, "[DEBUG] QuestionReview saved for $questionId\n", FILE_APPEND);
                } else {
                    file_put_contents($logFile, "[DEBUG] Proposition $propositionId not found\n", FILE_APPEND);
                }
            }

            file_put_contents($logFile, "[DEBUG] syncQuizSession completed successfully\n", FILE_APPEND);
            return true;
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] syncQuizSession failed: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n", FILE_APPEND);
            throw new \GraphQL\Error\Error("SyncQuizSession Failed: " . $e->getMessage() . " | " . $e->getFile() . ":" . $e->getLine());
        }
    }

    public function syncReview($root, array $args)
    {
        $logFile = storage_path('logs/debug.log');
        try {
            file_put_contents($logFile, "[DEBUG] syncReview called for question: " . $args['question_id'] . "\n", FILE_APPEND);
            $user = Auth::user();
            if (!$user) {
                file_put_contents($logFile, "[DEBUG] syncReview: No user authenticated\n", FILE_APPEND);
                return null;
            }

            $review = QuestionReview::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'question_id' => $args['question_id'],
                ],
                [
                    'interval' => $args['interval'],
                    'ease_factor' => $args['ease_factor'],
                    'repetition_count' => $args['repetition_count'],
                    'next_review' => $args['next_review'],
                    'last_review' => $args['last_review'],
                ]
            );
            file_put_contents($logFile, "[DEBUG] syncReview success\n", FILE_APPEND);
            return $review;
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] syncReview failed: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n", FILE_APPEND);
            // Throw a raw Exception so Lighthouse returns the actual error message in production
            throw new \GraphQL\Error\Error("Sync Failed: " . $e->getMessage() . " | " . $e->getFile() . ":" . $e->getLine());
        }
    }
}
