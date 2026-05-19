<?php

namespace App\GraphQL\Mutations;

use Illuminate\Support\Facades\Auth;

class NotificationResolver
{
    public function markAsRead($_, array $args)
    {
        $user = Auth::user();
        if (!$user) {
            return null;
        }

        $notification = $user->notifications()->where('id', $args['id'])->first();
        if ($notification) {
            $notification->markAsRead();

            $data = $notification->data;
            return [
                'id' => $notification->id,
                'title' => $data['title'] ?? '',
                'body' => $data['body'] ?? '',
                'type' => $notification->type,
                'data' => $data,
                'isRead' => true,
                'createdAt' => $notification->created_at,
            ];
        }

        return null;
    }

    public function delete($_, array $args)
    {
        $user = Auth::user();
        if (!$user) {
            return false;
        }

        $notification = $user->notifications()->where('id', $args['id'])->first();
        if ($notification) {
            $notification->delete();
            return true;
        }

        return false;
    }
}
