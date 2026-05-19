<?php

namespace App\GraphQL\Resolvers;

use App\Models\UserSetting;
use Illuminate\Support\Facades\Auth;

class UserSettingsResolver
{
    public function getSettings(): UserSetting
    {
        return UserSetting::firstOrCreate(
            ['user_id' => Auth::id()],
            [
                'pomodoro_work_duration' => 25,
                'pomodoro_short_break' => 5,
                'pomodoro_long_break' => 15,
                'pomodoro_sessions_until_long_break' => 4,
            ]
        );
    }

    public function updateSettings($_, array $args): UserSetting
    {
        $settings = $this->getSettings();

        $updateData = [];
        if (isset($args['work_duration']))
            $updateData['pomodoro_work_duration'] = $args['work_duration'];
        if (isset($args['short_break']))
            $updateData['pomodoro_short_break'] = $args['short_break'];
        if (isset($args['long_break']))
            $updateData['pomodoro_long_break'] = $args['long_break'];
        if (isset($args['sessions_until_long']))
            $updateData['pomodoro_sessions_until_long_break'] = $args['sessions_until_long'];

        $settings->update($updateData);
        return $settings;
    }
}
