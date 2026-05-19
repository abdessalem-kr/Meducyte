<?php

namespace App\GraphQL\Queries\Admin;

use App\Models\User;
use App\Models\Learn\Lesson;
use App\Models\Learn\Question;
use App\Models\Learn\QuestionReport;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardResolver
{
    public function getStats($rootValue, array $args)
    {
        // Total counts
        $totalUsers = User::count();
        $totalLessons = Lesson::count();
        $totalQuestions = Question::count();
        $totalAdmins = User::where('role', 'Admin')->count();

        // Active now (active in the last 15 minutes)
        $activeNow = User::where('updated_at', '>=', Carbon::now()->subMinutes(15))->count();

        // Active reports (not yet handled)
        $activeReports = QuestionReport::count(); // Assuming all are active for now

        // Growth and metrics (mocked for now, but in a real-world scenario you'd calculate these)
        $userGrowth = "+12% from last week";
        $lessonGrowth = "3 new added today";
        $questionAccuracy = "98% accuracy rate";

        return [
            'totalUsers' => $totalUsers,
            'activeNow' => $activeNow,
            'totalAdmins' => $totalAdmins,
            'totalLessons' => $totalLessons,
            'totalQuestions' => $totalQuestions,
            'activeReports' => $activeReports,
            'userGrowth' => $userGrowth,
            'lessonGrowth' => $lessonGrowth,
            'questionAccuracy' => $questionAccuracy,
        ];
    }

    public function getServerStatus($rootValue, array $args)
    {
        try {
            \DB::connection()->getPdo();
            $dbStatus = 'Connected';
        } catch (\Exception $e) {
            $dbStatus = 'Error: ' . $e->getMessage();
        }

        $memoryUsage = memory_get_usage(true);
        $memoryFormatted = round($memoryUsage / 1024 / 1024, 2) . ' MB';

        $diskFree = disk_free_space("/");
        $diskTotal = disk_total_space("/");
        $diskUsage = round((($diskTotal - $diskFree) / $diskTotal) * 100, 2);

        // Uptime (rough estimate using process start time if available, or just uptime command)
        $uptime = shell_exec('uptime -p') ?? 'Unknown';

        return [
            'status' => 'Healthy',
            'dbConnection' => $dbStatus,
            'memoryUsage' => $memoryFormatted,
            'diskUsage' => $diskUsage,
            'phpVersion' => PHP_VERSION,
            'laravelVersion' => app()->version(),
            'environment' => app()->environment(),
            'uptime' => trim($uptime),
        ];
    }

    public function getActivities($rootValue, array $args)
    {
        $activities = collect();

        // 1. Recent Signups
        $recentUsers = User::latest()->limit(5)->get();
        foreach ($recentUsers as $user) {
            $activities->push([
                'id' => 'user_' . $user->id,
                'type' => 'user',
                'title' => 'New User Registration',
                'subtitle' => $user->name . ' joined the platform',
                'time' => $user->created_at->diffForHumans(),
                'priority' => 'low',
                'raw_time' => $user->created_at
            ]);
        }

        // 2. Recent Reports
        $recentReports = QuestionReport::latest()->limit(5)->get();
        foreach ($recentReports as $report) {
            $activities->push([
                'id' => 'report_' . $report->id,
                'type' => 'report',
                'title' => 'New Question Report',
                'subtitle' => 'Issue reported: ' . $report->reason,
                'time' => $report->created_at->diffForHumans(),
                'priority' => 'high',
                'raw_time' => $report->created_at
            ]);
        }

        // 3. Recent Lessons
        $recentLessons = Lesson::latest()->limit(5)->get();
        foreach ($recentLessons as $lesson) {
            $activities->push([
                'id' => 'lesson_' . $lesson->id,
                'type' => 'content',
                'title' => 'Lesson Added',
                'subtitle' => 'New lesson: ' . $lesson->title,
                'time' => $lesson->created_at->diffForHumans(),
                'priority' => 'medium',
                'raw_time' => $lesson->created_at
            ]);
        }

        return $activities->sortByDesc('raw_time')->values()->take(10)->toArray();
    }
}
