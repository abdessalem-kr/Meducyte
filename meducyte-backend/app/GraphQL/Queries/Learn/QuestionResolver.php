<?php

namespace App\GraphQL\Queries\Learn;

use App\Models\Learn\Question;
use App\Models\Learn\QuestionReview;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class QuestionResolver
{
    public function filter($root, array $args)
    {
        $logFile = storage_path('logs/debug.log');
        try {
            file_put_contents($logFile, "[DEBUG] filter called with: " . json_encode($args) . "\n", FILE_APPEND);

            $query = Question::query();

            if (isset($args['moduleIds']) && !empty($args['moduleIds'])) {
                $query->whereHas('lesson', function (Builder $q) use ($args) {
                    $q->whereIn('module_id', $args['moduleIds']);
                });
            }

            if (isset($args['years']) && !empty($args['years'])) {
                $query->whereHas('lesson.module', function (Builder $q) use ($args) {
                    $q->whereIn('year', $args['years']);
                });
            }

            if (isset($args['lessonIds']) && !empty($args['lessonIds'])) {
                $query->whereIn('lesson_id', $args['lessonIds']);
            }

            if (isset($args['sources']) && !empty($args['sources'])) {
                $query->whereIn('source_exam', $args['sources']);
            }

            if (isset($args['ids'])) {
                $query->whereIn('id', $args['ids']);
            }

            if (isset($args['tags'])) {
                foreach ($args['tags'] as $tag) {
                    $query->whereJsonContains('tags', $tag);
                }
            }

            if (isset($args['hasClinicalCase'])) {
                if ($args['hasClinicalCase']) {
                    $query->whereNotNull('clinical_case_id');
                } else {
                    $query->whereNull('clinical_case_id');
                }
            }

            $limit = $args['limit'] ?? 100;
            $offset = $args['offset'] ?? 0;

            $results = $query->orderBy('clinical_case_id', 'asc')
                ->with(['propositions', 'lesson.module'])
                ->offset($offset)
                ->limit($limit)
                ->get();
            file_put_contents($logFile, "[DEBUG] filter found " . $results->count() . " results\n", FILE_APPEND);
            return $results;
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] filter failed: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n", FILE_APPEND);
            throw $e;
        }
    }

    public function sources($root, array $args)
    {
        return Question::whereNotNull('source_exam')
            ->distinct()
            ->pluck('source_exam');
    }

    /**
     * Resolver for Question.review
     */
    public function review($root)
    {
        $logFile = storage_path('logs/debug.log');
        try {
            $user = Auth::user();
            if (!$user)
                return null;

            $questionId = $root->id ?? ($root['id'] ?? null);
            if (!$questionId)
                return null;

            return QuestionReview::where('user_id', $user->id)
                ->where('question_id', $questionId)
                ->first();
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] review failed: " . $e->getMessage() . "\n", FILE_APPEND);
            throw new \GraphQL\Error\Error("Review Fetch Failed: " . $e->getMessage() . " | " . $e->getFile() . ":" . $e->getLine());
        }
    }

    /**
     * Resolver for Query.myReviews
     */
    public function myReviews($root, array $args)
    {
        $logFile = storage_path('logs/debug.log');
        try {
            file_put_contents($logFile, "[DEBUG] myReviews called\n", FILE_APPEND);
            $user = Auth::user();
            if (!$user) {
                file_put_contents($logFile, "[DEBUG] myReviews: No user authenticated\n", FILE_APPEND);
                return [];
            }

            $results = QuestionReview::where('user_id', $user->id)->get();
            file_put_contents($logFile, "[DEBUG] myReviews found " . $results->count() . " results\n", FILE_APPEND);
            return $results;
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] myReviews failed: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n", FILE_APPEND);
            throw new \GraphQL\Error\Error("myReviews Fetch Failed: " . $e->getMessage() . " | " . $e->getFile() . ":" . $e->getLine());
        }
    }
}
