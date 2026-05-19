<?php

namespace App\GraphQL\Mutations\Learn;

use App\Models\Learn\UserNote;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class NoteResolver
{
    /**
     * Store a private note for a question
     */
    public function store($_, array $args)
    {
        $user = Auth::user();

        $v = Validator::make($args, [
            'question_id' => 'required|integer|exists:questions,id',
            'text' => 'required|string|max:2000',
        ]);

        if ($v->fails()) {
            throw new ValidationException($v);
        }

        $text = strip_tags($args['text']);

        return DB::transaction(function () use ($user, $args, $text) {
            return UserNote::create([
                'user_id' => $user->id,
                'question_id' => $args['question_id'],
                'text' => $text,
            ]);
        });
    }

    /**
     * Delete a user note (only owner)
     */
    public function delete($_, array $args)
    {
        $user = Auth::user();
        $note = UserNote::find($args['id']);

        if (!$note || $note->user_id !== $user->id) {
            abort(403, 'Forbidden');
        }

        return (bool) $note->delete();
    }
}