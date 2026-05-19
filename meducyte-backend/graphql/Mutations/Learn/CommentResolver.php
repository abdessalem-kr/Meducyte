<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\UserComment;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class CommentResolver
{
    public function store($_, array $args)
    {
        $user = Auth::user();

        $v = Validator::make($args, [
            'question_id' => 'required|integer|exists:questions,id',
            'text' => 'required|string|min:1|max:1000',
        ]);

        if ($v->fails()) {
            throw new ValidationException($v);
        }

        $questionId = (int) $args['question_id'];
        $text = strip_tags($args['text']);

        return DB::transaction(function () use ($user, $questionId, $text) {
            // Limit max 3 comments per user per question
            $count = UserComment::where('user_id', $user->id)
                ->where('question_id', $questionId)
                ->count();

            if ($count >= 3) {
                abort(429, 'Comment limit reached (3 per question).');
            }

            return UserComment::create([
                'user_id' => $user->id,
                'question_id' => $questionId,
                'text' => $text,
            ]);
        });
    }

    public function delete($_, array $args)
    {
        $user = Auth::user();
        $comment = UserComment::find($args['id']);

        if (!$comment || $comment->user_id !== $user->id) {
            abort(403, 'Forbidden');
        }

        return (bool) $comment->delete();
    }
}