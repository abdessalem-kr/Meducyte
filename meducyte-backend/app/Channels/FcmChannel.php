<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

class FcmChannel
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    public function send($notifiable, Notification $notification)
    {
        if (!method_exists($notification, 'toFcm')) {
            return;
        }

        $tokens = $notifiable->routeNotificationFor('Fcm', $notification);

        if (empty($tokens)) {
            return;
        }

        $messagePayload = $notification->toFcm($notifiable);

        \Log::info('Sending FCM Notification', [
            'user_id' => $notifiable->id,
            'tokens' => $tokens,
            'title' => $messagePayload['title'] ?? '',
        ]);

        $cloudMessage = CloudMessage::new()
            ->withNotification(FcmNotification::create(
                $messagePayload['title'] ?? '',
                $messagePayload['body'] ?? ''
            ))
            ->withAndroidConfig([
                'priority' => 'high',
                'notification' => [
                    'channel_id' => 'high_importance_channel',
                    'sound' => 'default',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
            ])
            ->withApnsConfig([
                'payload' => [
                    'aps' => [
                        'alert' => [
                            'title' => $messagePayload['title'] ?? '',
                            'body' => $messagePayload['body'] ?? '',
                        ],
                        'sound' => 'default',
                        'badge' => 1,
                        'content-available' => 1,
                    ],
                ],
            ]);

        if (!empty($messagePayload['data'])) {
            // FCM data payloads must be an array of strings
            $stringifiedData = array_map('strval', $messagePayload['data']);
            $cloudMessage = $cloudMessage->withData($stringifiedData);
        }

        try {
            if (is_array($tokens)) {
                $this->messaging->sendMulticast($cloudMessage, $tokens);
            } else {
                $this->messaging->send($cloudMessage->withChangedTarget('token', $tokens));
            }
        } catch (\Throwable $e) {
            \Log::error('FCM Notification Failed: ' . $e->getMessage());
        }
    }
}
