<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'role',
        'password',
        'year',
        'mobile',
        'interests',
        'learning_goal',
        'heard_from',
        'quiz_preference',
        'study_time',
        'study_duration',
        'avatar_key',
        'faculte',
        'enable_daily_challenge',
        'show_to_faculty',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'interests' => 'array', 
        'enable_daily_challenge' => 'boolean',
        'show_to_faculty' => 'boolean',
    ];

    protected $appends = ['next_exam_date'];

    public function examEvents(): HasMany
    {
        return $this->hasMany(ExamEvent::class);
    }

    public function getNextExamDateAttribute()
    {
        return $this->examEvents()->orderBy('date', 'desc')->first()?->date;
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function activeSubscription()
    {
        return $this->hasOne(Subscription::class)
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->latest();
    }

    public function canAccessModule($module)
    {
        $sub = $this->activeSubscription;
        if (!$sub)
            return false;

        // Basic plans only get quizzes, NOT modules (lessons)
        if (!$sub->plan->has_ai_access) {
            return false;
        }

        // Residency level gets full access to all modules
        if ($sub->plan->access_level === 'residency') {
            return true;
        }

        // Students get access to modules matching their year
        if ($sub->plan->access_level === 'student' && $module->year == $this->year) {
            return true;
        }

        return false;
    }

    public function hasAiAccess()
    {
        $sub = $this->activeSubscription;
        return $sub && $sub->plan->has_ai_access;
    }

    public function routeNotificationForFcm()
    {
        // Get non-null FCM tokens from the user's active personal access tokens
        return $this->tokens()->whereNotNull('fcm_token')->pluck('fcm_token')->toArray();
    }

    public function studyGroups()
    {
        return $this->belongsToMany(StudyGroup\StudyGroup::class, 'study_group_members');
    }

    public function studiedLessons()
    {
        return $this->belongsToMany(Learn\Lesson::class, 'studied_lessons');
    }
}