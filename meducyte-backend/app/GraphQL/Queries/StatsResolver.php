<?php

namespace App\GraphQL\Queries;

use App\Models\Learn\UserAnswer;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

class StatsResolver
{
    /**
     * Get statistics for the currently authenticated user.
     *
     * @param  mixed  $rootValue
     * @param  array  $args
     * @return array
     */
    public function getMyStats($rootValue, array $args): array
    {
        $logFile = storage_path('logs/debug.log');
        try {
            file_put_contents($logFile, "[DEBUG] getMyStats called\n", FILE_APPEND);
            $user = Auth::user();
            if (!$user) {
                file_put_contents($logFile, "[DEBUG] getMyStats: No user authenticated\n", FILE_APPEND);
                throw new \GraphQL\Error\Error("Unauthenticated request to myStats.");
            }

            // Defensive check if user_answers table exists
            if (!Schema::hasTable('user_answers')) {
                file_put_contents($logFile, "[DEBUG] getMyStats: user_answers table does not exist. Returning empty stats.\n", FILE_APPEND);
                return [
                    'overallAccuracy' => 0.0,
                    'quizzesCompleted' => 0,
                    'questionsAnswered' => 0,
                    'questionsAnsweredToday' => 0,
                    'studyStreak' => 0,
                    'specialtyAccuracy' => (object) [],
                    'performanceTrend' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                ];
            }

            $hasStudiedLessonsTable = Schema::hasTable('studied_lessons');

            // 1. Questions Answered and Correct Answers
            $totalAnswers = UserAnswer::where('user_id', $user->id)->count();
            $correctAnswers = UserAnswer::where('user_id', $user->id)->where('is_correct', true)->count();
            $questionsAnsweredToday = UserAnswer::where('user_id', $user->id)
                ->whereDate('created_at', Carbon::today())
                ->count();

            $overallAccuracy = $totalAnswers > 0 ? round($correctAnswers / $totalAnswers, 4) : 0.0;

            // 2. Quizzes Completed (Grouped by actual quiz_session_id, with a 30-minute fallback for legacy answers)
            $quizzesCompleted = UserAnswer::where('user_id', $user->id)
                ->whereNotNull('quiz_session_id')
                ->distinct('quiz_session_id')
                ->count('quiz_session_id');

            $legacyAnswers = UserAnswer::where('user_id', $user->id)
                ->whereNull('quiz_session_id')
                ->orderBy('created_at')
                ->get();

            $lastTime = null;
            foreach ($legacyAnswers as $ans) {
                $time = Carbon::parse($ans->created_at);
                if ($lastTime === null || $time->diffInMinutes($lastTime) > 30) {
                    $quizzesCompleted++;
                }
                $lastTime = $time;
            }

            // 3. Study Streak (Consecutive days of study based on user_answers and studied_lessons)
            $streak = 0;
            $checkDate = Carbon::today();

            $hasActivityToday = UserAnswer::where('user_id', $user->id)->whereDate('created_at', $checkDate)->exists()
                || ($hasStudiedLessonsTable && DB::table('studied_lessons')->where('user_id', $user->id)->whereDate('created_at', $checkDate)->exists());

            if (!$hasActivityToday) {
                $checkDate->subDay();
            }

            while (true) {
                $hasActivity = UserAnswer::where('user_id', $user->id)->whereDate('created_at', $checkDate)->exists()
                    || ($hasStudiedLessonsTable && DB::table('studied_lessons')->where('user_id', $user->id)->whereDate('created_at', $checkDate)->exists());

                if (!$hasActivity) {
                    break;
                }
                $streak++;
                $checkDate->subDay();
            }

            // 4. Specialty Accuracy (Grouped by module name in PHP to be DB-agnostic)
            $userAnswersForModules = UserAnswer::with(['question.lesson.module'])
                ->where('user_id', $user->id)
                ->get();

            $grouped = $userAnswersForModules->groupBy(function ($ua) {
                return $ua->question->lesson->module->name ?? 'Unknown';
            });

            $specialtyAccuracy = [];
            foreach ($grouped as $moduleName => $group) {
                if ($moduleName === 'Unknown') {
                    continue;
                }
                $total = $group->count();
                $correct = $group->where('is_correct', true)->count();
                $specialtyAccuracy[$moduleName] = $total > 0 ? round($correct / $total, 4) : 0.0;
            }

            // 5. Performance Trend (Last 7 days accuracy list)
            $performanceTrend = [];
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::today()->subDays($i);
                $dayAnswers = UserAnswer::where('user_id', $user->id)
                    ->whereDate('created_at', $date)
                    ->get();

                if ($dayAnswers->isEmpty()) {
                    $performanceTrend[] = 0.0;
                } else {
                    $correct = $dayAnswers->where('is_correct', true)->count();
                    $performanceTrend[] = round($correct / $dayAnswers->count(), 4);
                }
            }

            $result = [
                'overallAccuracy' => $overallAccuracy,
                'quizzesCompleted' => $quizzesCompleted,
                'questionsAnswered' => $totalAnswers,
                'questionsAnsweredToday' => $questionsAnsweredToday,
                'studyStreak' => $streak,
                'specialtyAccuracy' => empty($specialtyAccuracy) ? (object) [] : $specialtyAccuracy,
                'performanceTrend' => $performanceTrend,
            ];

            file_put_contents($logFile, "[DEBUG] getMyStats success: " . json_encode($result) . "\n", FILE_APPEND);
            return $result;
        } catch (\Throwable $e) {
            file_put_contents($logFile, "[ERROR] getMyStats failed: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n", FILE_APPEND);
            throw new \GraphQL\Error\Error("Failed to fetch user statistics: " . $e->getMessage());
        }
    }
}
