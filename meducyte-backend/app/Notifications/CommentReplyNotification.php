<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use App\Models\Learn\QuestionComment;

class CommentReplyNotification extends Notification
{
    use Queueable;

    public $replyComment;

    public function __construct(QuestionComment $replyComment)
    {
        $this->replyComment = $replyComment;
    }

    public function via($notifiable)
    {
        return ['database', \App\Channels\FcmChannel::class];
    }

    public function toDatabase($notifiable)
    {
        return [
            'title' => 'New Reply to Your Comment',
            'body' => $this->replyComment->user->name . ' replied: "' . mb_strimwidth($this->replyComment->text, 0, 50, "...") . '"',
            'type' => 'comment_reply',
            'question_id' => $this->replyComment->question_id,
            'comment_id' => $this->replyComment->id,
        ];
    }

    public function toFcm($notifiable)
    {
        return [
            'title' => 'New Reply to Your Comment',
            'body' => $this->replyComment->user->name . ' replied: "' . mb_strimwidth($this->replyComment->text, 0, 50, "...") . '"',
            'data' => [
                'type' => 'comment_reply',
                'question_id' => $this->replyComment->question_id,
                'comment_id' => $this->replyComment->id,
            ],
        ];
    }
}
