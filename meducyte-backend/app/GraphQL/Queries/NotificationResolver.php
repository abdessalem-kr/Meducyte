<?php

namespace App\GraphQL\Queries;

use Illuminate\Support\Facades\Auth;

class NotificationResolver
{
    public function myNotifications($_, array $args)
    {
        $user = Auth::user();

        if (!$user) {
            return [];
        }

        return $user->notifications()->latest()->get()->map(function ($notification) {
            $data = $notification->data;
            return [
                'id' => $notification->id,
                'title' => $data['title'] ?? '',
                'body' => $data['body'] ?? '',
                'type' => $notification->type,
                'data' => $data,
                'isRead' => $notification->read_at !== null,
                'createdAt' => $notification->created_at,
            ];
        });
    }
}
